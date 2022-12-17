//
//  AdventureMapModel.swift
//  STRAY-IT
//
//  Created by Kanta Oikawa on 2022/12/17.
//

import Foundation
import MapKit
import SwiftUI

struct AdventureMapView: UIViewRepresentable {
    @EnvironmentObject var manager: LocationManager
    let mapManager = AdventureMapManager()
    
    func makeUIView(context: Self.Context) -> UIViewType {
        let mapView = mapManager.mapViewObj
        
        let basePin1 = manager.places["start"]!
        let basePin2 = manager.places["goal"]!
        
        mapView.addAnnotation(basePin1)
        mapView.addAnnotation(basePin2)
        
        let basePlaceMark1 = MKPlacemark(coordinate: basePin1.coordinate)
        let basePlaceMark2 = MKPlacemark(coordinate: basePin2.coordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: basePlaceMark1)
        directionRequest.destination = MKMapItem(placemark: basePlaceMark2)
        directionRequest.transportType = MKDirectionsTransportType.walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            
            let route = directionResonse.routes[0]
            
            mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            var rectRegion = MKCoordinateRegion(rect)
            rectRegion.span.latitudeDelta = rectRegion.span.latitudeDelta * 1.2
            rectRegion.span.longitudeDelta = rectRegion.span.longitudeDelta * 1.2
            mapView.setRegion(rectRegion, animated: true)
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Self.Context) {
        uiView.delegate = mapManager
    }
}

struct AdventureMapView_Previews: PreviewProvider {
    static var previews: some View {
        AdventureMapView()
            .environmentObject(LocationManager())
    }
}

class AdventureMapManager: NSObject, MKMapViewDelegate{
    var mapViewObj = MKMapView()
    
    override init() {
        super.init()
        mapViewObj.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(named: "RouteColor")
        renderer.lineWidth = 8.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "annotation"
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier
            )
            
            annotationView.markerTintColor = UIColor(named: "RouteColor")
            annotationView.glyphImage = UIImage(named: "Marker")
            annotationView.canShowCallout = true
//            annotationView.image = UIImage(named: "Marker")
            
            return annotationView
        }
    }
}
