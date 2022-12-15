//
//  MapModel.swift
//  STRAY-IT
//
//  Created by Kanta Oikawa on 2022/12/11.
//

import Foundation
import MapKit

class ViewStates: ObservableObject {
    @Published var searchViewIsShowing = true
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
    
    init(id: UUID = UUID(), location: CLLocationCoordinate2D, title: String) {
        self.id = id
        self.location = location
        self.title = title
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion()
    @Published var places: [String: IdentifiablePlace?] = ["start": nil, "goal": nil]
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
}

extension LocationManager {
    
    func calculateDelta() {
        if (places["goal"] != nil) {
            let currentCoordinate = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            let goalCoordinate = CLLocation(latitude: places["goal"]??.location.latitude ?? 0, longitude: places["goal"]??.location.longitude ?? 0)
            delta = currentCoordinate.distance(from: goalCoordinate)
        }
    }
    
    func calculateDestinationDirection() {
        if (places["goal"] != nil) {
            let currentLatitude = toRadian(region.center.latitude)
            let currentLongitude = toRadian(region.center.longitude)
            let targetLatitude = toRadian(places["goal"]??.location.latitude ?? 0)
            let targetLongitude = toRadian(places["goal"]??.location.longitude ?? 0)
            
            let longitudeDelta = targetLongitude - currentLongitude
            let y = sin(longitudeDelta)
            let x = cos(currentLatitude) * tan(targetLatitude) - sin(currentLatitude) * cos(longitudeDelta)
            let p = atan2(y, x) * 180 / CGFloat.pi
            
            if p < 0 {
                destinationDirection = 360 + atan2(y, x) * 180 / CGFloat.pi
            } else {
                destinationDirection = atan2(y, x) * 180 / CGFloat.pi
            }
            
            destinationDirection -= headingDirection
        }
    }
    
    func toRadian(_ angle: CGFloat) -> CGFloat {
        return angle * CGFloat.pi / 180
    }
    
    func setDestination(_ destination: IdentifiablePlace) {
        places["start"] = IdentifiablePlace(location: region.center, title: "")
        places["goal"] = destination
        
        calculateDelta()
        calculateDestinationDirection()
    }
}


class LocationSearcher {
    
    let request = MKLocalSearch.Request()
    @Published var results: [MKMapItem] = []
    
    func setRegion(_ region: MKCoordinateRegion) {
        request.region = region
    }
    
    func updateQueryText(_ text: String) {
        request.naturalLanguageQuery = text
        
        executeQuery()
    }
    
    func executeQuery() {
        if (request.naturalLanguageQuery != "") {
            let search = MKLocalSearch(request: request)
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                
                self.results = response.mapItems
            }
        }
    }
}

extension LocationSearcher {
    
    func getLocationName(_ location: MKMapItem) -> String? {
        return location.name
    }
    
    func getLocationPointOfInterestCategory(_ location: MKMapItem) -> MKPointOfInterestCategory? {
        return location.pointOfInterestCategory
    }
    
    func getLocationPointOfInterestCategoryRawValue(_ location: MKMapItem) -> String? {
        return location.pointOfInterestCategory?.rawValue
    }
    
    func getLocationCoordinate(_ location: MKMapItem) -> CLLocationCoordinate2D {
        return location.placemark.coordinate
    }
}
