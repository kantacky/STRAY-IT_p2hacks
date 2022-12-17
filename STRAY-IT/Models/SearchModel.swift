//
//  SearchModel.swift
//  STRAY-IT
//
//  Created by Kanta Oikawa on 2022/12/17.
//

import Foundation
import MapKit

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
