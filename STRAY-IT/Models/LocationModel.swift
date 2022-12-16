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

class Landmark: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    let name: String
    let pointOfInterestCategory: MKPointOfInterestCategory?
    var direction: CGFloat
    
    init(id: UUID = UUID(), location: CLLocationCoordinate2D, name: String?, pointOfInterestCategory: MKPointOfInterestCategory?) {
        self.id = id
        self.location = location
        self.name = name ?? "No Name"
        self.pointOfInterestCategory = pointOfInterestCategory
        self.direction = 0
    }
    
    func setDirection(_ newDirection: CGFloat) {
        direction = newDirection
    }
    
    func getPointOfInterestCategoryImageName() -> String? {
        if (pointOfInterestCategory != nil) {
            switch (pointOfInterestCategory!) {
            case .atm:
                return "Atm"
            case .bakery:
                return "Bakery"
            case .bank:
                return "Bank"
            case .cafe:
                return "Cafe"
            case .carRental:
                return "CarRental"
            case .fireStation:
                return "FireStation"
            case .fitnessCenter:
                return "FitnessCenter"
            case .foodMarket:
                return "FoodMarket"
            case .gasStation:
                return "GasStation"
            case .hospital:
                return "Hospital"
            case .hotel:
                return "Hotel"
            case .laundry:
                return "Laundry"
            case .library:
                return "Library"
            case .movieTheater:
                return "MovieTheater"
            case .museum:
                return "Museum"
            case .park:
                return "Park"
            case .parking:
                return "Parking"
            case .pharmacy:
                return "Pharmacy"
            case .police:
                return "Police"
            case .postOffice:
                return "PostOffice"
            case .publicTransport:
                return "PublicTransport"
            case .restaurant:
                return "Restaurant"
            case .restroom:
                return "Restroom"
            case .school:
                return "School"
            case .store:
                return "Store"
            case .university:
                return "University"
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    let landmarkSearcher = LandmarkSearcher()
    
    @Published var isDiscovering = false
    @Published var region = MKCoordinateRegion()
    private var landmarksRegion = MKCoordinateRegion()
    @Published var places: [String: IdentifiablePlace?] = ["start": nil, "goal": nil]
    @Published var landmarks: [Landmark] = []
    @Published var headingDirection: Double = 0
    @Published var destinationDirection: Double = 0
    @Published var delta: Double = 0
    private var landmarksRadius: CLLocationDistance = 50.0
    
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
            
            landmarksRegion = MKCoordinateRegion(
                center: center,
                latitudinalMeters: landmarksRadius,
                longitudinalMeters: landmarksRadius
            )
        }
        
        if (isDiscovering) {
            landmarkSearcher.searchNearHear(center: region.center, radius: region.span.latitudeDelta)
            makeLandmarkList()
            calculateLandmarksDirection()
            calculateDeltaFromHereToGoal()
            calculateDestinationDirection()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        headingDirection = heading.magneticHeading
        
        if (isDiscovering) {
            calculateDeltaFromHereToGoal()
            calculateDestinationDirection()
            calculateLandmarksDirection()
        }
    }
}

extension LocationManager {
    
    func calculateDelta(_ originalCoordinate: CLLocation, _ targetCoordinate: CLLocation) -> CGFloat {
        return originalCoordinate.distance(from: targetCoordinate)
    }
    
    func calculateDeltaFromHereToGoal() {
        if (places["goal"] != nil) {
            let currentCoordinate = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            let goalCoordinate = CLLocation(latitude: places["goal"]??.location.latitude ?? 0, longitude: places["goal"]??.location.longitude ?? 0)
            delta = calculateDelta(currentCoordinate, goalCoordinate)
        }
    }
    
    func toRadian(_ angle: CGFloat) -> CGFloat {
        return angle * CGFloat.pi / 180
    }
    
    func setDestination(_ destination: IdentifiablePlace) {
        places["start"] = IdentifiablePlace(location: region.center, title: "")
        places["goal"] = destination
        
        calculateDeltaFromHereToGoal()
        calculateDestinationDirection()
    }
    
    private func calculateDirection(_ originalCoordinate: CLLocationCoordinate2D, _ targetCoordinate: CLLocationCoordinate2D) -> CGFloat {
        var direction: CGFloat
        
        let originalLatitude = toRadian(originalCoordinate.latitude)
        let originalLongitude = toRadian(originalCoordinate.longitude)
        let targetLatitude = toRadian(targetCoordinate.latitude)
        let targetLongitude = toRadian(targetCoordinate.longitude)
        
        let longitudeDelta = targetLongitude - originalLongitude
        let y = sin(longitudeDelta)
        let x = cos(originalLatitude) * tan(targetLatitude) - sin(originalLatitude) * cos(longitudeDelta)
        let p = atan2(y, x) * 180 / CGFloat.pi
        
        if p < 0 {
            direction = 360 + atan2(y, x) * 180 / CGFloat.pi
        } else {
            direction = atan2(y, x) * 180 / CGFloat.pi
        }
        
        direction -= headingDirection
        
        return direction
    }
    
    private func calculateDestinationDirection() {
        if (places["goal"] != nil) {
            destinationDirection = calculateDirection(region.center, places["goal"]??.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }
    }
    
    private func makeLandmarkList() {
        for item in landmarkSearcher.results {
            let name = landmarkSearcher.getLocationName(item)
            let location = landmarkSearcher.getLocationCoordinate(item)
            let category = landmarkSearcher.getLocationPointOfInterestCategory(item)
            var isMultiple = false
            for landmark in landmarks {
                if (landmark.location.latitude == location.latitude && landmark.location.longitude == location.longitude) {
                    isMultiple = true
                }
                if (calculateDelta(CLLocation(latitude: landmark.location.latitude, longitude: landmark.location.longitude), CLLocation(latitude: location.latitude, longitude: location.longitude)) > landmarksRadius) {
                    landmarks.remove(at: landmarks.firstIndex(where: {$0.id == landmark.id})!)
                }
            }
            if (!isMultiple) {
                landmarks.append(Landmark(location: location, name: name, pointOfInterestCategory: category))
            }
        }
    }
    
    private func calculateLandmarksDirection() {
        landmarks.forEach { item in
            item.setDirection(calculateDirection(region.center, item.location))
        }
    }
    
    func calculatePosition(_ radius: CGFloat, _ degrees: CGFloat) -> [CGFloat] {
        let theta = toRadian(degrees)
        let x = radius * cos(theta)
        let y = radius * sin(theta)
        
        return [x, y]
    }
}


class LocationSearcher {
    
    private var request: MKLocalSearch.Request
    private var search: MKLocalSearch
    @Published var results: [MKMapItem] = []
    
    init() {
        request = MKLocalSearch.Request()
        request.resultTypes = [.address, .pointOfInterest]
        search = MKLocalSearch(request: request)
    }
    
    public func setRegion(_ region: MKCoordinateRegion) {
        request.region = region
    }
    
    public func updateQueryText(_ text: String) {
        request.naturalLanguageQuery = text
        
        searchQuery()
    }
    
    public func executeQuery() {
        search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            self.results = response.mapItems
        }
    }
    
    public func searchQuery() {
        if (request.naturalLanguageQuery != "") {
            executeQuery()
        }
    }
}

extension LocationSearcher {
    
    public func getLocationName(_ location: MKMapItem) -> String? {
        return location.name
    }
    
    public func getLocationPointOfInterestCategory(_ location: MKMapItem) -> MKPointOfInterestCategory? {
        return location.pointOfInterestCategory
    }
    
    public func getLocationPointOfInterestCategoryRawValue(_ location: MKMapItem) -> String? {
        return location.pointOfInterestCategory?.rawValue
    }
    
    public func getLocationCoordinate(_ location: MKMapItem) -> CLLocationCoordinate2D {
        return location.placemark.coordinate
    }
    
    public func isSearching() -> Bool {
        return search.isSearching
    }
}

class LandmarkSearcher {
    
    private var request: MKLocalPointsOfInterestRequest
    private var search: MKLocalSearch
    @Published var results: [MKMapItem]
    
    init() {
        request = MKLocalPointsOfInterestRequest(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 1)
        search = MKLocalSearch(request: request)
        results = []
    }
    
    public func makeRequest(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        request = MKLocalPointsOfInterestRequest(center: center, radius: radius)
    }
    
    public func searchNearHear(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        makeRequest(center: center, radius: radius)
        search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            self.results = response.mapItems
        }
    }
}

extension LandmarkSearcher {
    
    public func getLocationName(_ location: MKMapItem) -> String? {
        return location.name
    }
    
    public func getLocationPointOfInterestCategory(_ location: MKMapItem) -> MKPointOfInterestCategory? {
        return location.pointOfInterestCategory
    }
    
    public func getLocationPointOfInterestCategoryRawValue(_ location: MKMapItem) -> String? {
        return location.pointOfInterestCategory?.rawValue
    }
    
    public func getLocationCoordinate(_ location: MKMapItem) -> CLLocationCoordinate2D {
        return location.placemark.coordinate
    }
}
