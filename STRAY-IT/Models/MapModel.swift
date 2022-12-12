//
//  MapModel.swift
//  STRAY-IT
//
//  Created by Kanta Oikawa on 2022/12/11.
//

import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion()
    @Published var start_and_goal: [IdentifiablePlace] = [IdentifiablePlace(latitude: MKCoordinateRegion().center.latitude, longitude: MKCoordinateRegion().center.longitude, title: "現在地"), IdentifiablePlace(latitude: MKCoordinateRegion().center.latitude, longitude: MKCoordinateRegion().center.longitude, title: "目的地")]
    @Published var headingDirection: Double = 0
    @Published var destinationDirection: Double = 0
    @Published var delta: Double = 0
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 1.0
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        
        start_and_goal = [
            IdentifiablePlace(latitude: region.center.latitude, longitude: region.center.longitude, title: "出発地"),
            IdentifiablePlace(latitude: 41.7895949, longitude: 140.7519594, title: "無印良品シエスタハコダテ")
        ]
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            let center = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            
            region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 1000.0,
                longitudinalMeters: 1000.0
            )
        }
        
        calculateDelta()
        calculateDestinationDirection()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        headingDirection = heading.magneticHeading
        
        calculateDelta()
        calculateDestinationDirection()
    }
    
    func calculateDelta() {
        let currentCoordinate = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let goalCoordinate = CLLocation(latitude: start_and_goal[1].location.latitude, longitude: start_and_goal[1].location.longitude)
        delta = currentCoordinate.distance(from: goalCoordinate)
    }
    
    func calculateDestinationDirection() {
        let currentLatitude = toRadian(region.center.latitude)
        let currentLongitude = toRadian(region.center.longitude)
        let targetLatitude = toRadian(start_and_goal[1].location.latitude)
        let targetLongitude = toRadian(start_and_goal[1].location.longitude)
        
        let longitudeDelta = targetLongitude - currentLongitude
        let y = sin(longitudeDelta)
        let x = cos(currentLatitude) * tan(targetLatitude) - sin(currentLatitude) * cos(longitudeDelta)
        let p = atan2(y, x) * 180 / CGFloat.pi
        
        if p < 0 {
            destinationDirection = 360 + atan2(y, x) * 180 / CGFloat.pi
        } else {
            destinationDirection = atan2(y, x) * 180 / CGFloat.pi
        }
        
        if (destinationDirection < headingDirection) {
            destinationDirection = headingDirection - destinationDirection
        } else {
            destinationDirection -= headingDirection
        }
    }
    
    func toRadian(_ angle: CGFloat) -> CGFloat {
        return angle * CGFloat.pi / 180
    }
}

struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    let title: String
    
    init(id: UUID = UUID(), latitude: Double, longitude: Double, title: String) {
        self.id = id
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = title
    }
}
