//
//  CheatingView.swift
//  STRAY-IT
//
//  Created by inoue mei on 2022/12/15.
//

import SwiftUI
import MapKit

struct CheatingView: UIViewRepresentable {
    @EnvironmentObject var manager: LocationManager
    let Manager = LocationManager()
    
    func makeUIView(context: Self.Context) -> MKMapView{
        MKMapView()
       // let mapView = Manager.mapViewObj
    }
    
    let directionRequest = MKDirections.Request()
    
   
    func updateUIView(_ uiView: MKMapView, context: Self.Context) {
       }
   }

    
struct CheatingView_Previews: PreviewProvider {
    static var previews: some View {
        CheatingView()
    }
}

