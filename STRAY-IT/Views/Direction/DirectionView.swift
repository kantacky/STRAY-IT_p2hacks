//
//  DirectionView.swift
//  STRAY-IT
//
//  Created by Kanta Oikawa on 2022/12/11.
//

import SwiftUI
import MapKit

struct DirectionView: View {
    @EnvironmentObject var manager: LocationManager
    
    var body: some View {
        ZStack {
            Image("DirectionViewDecoration")
            
            Image("Direction")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .rotationEffect(.degrees(manager.destinationDirection))
            
            Text("\(Int(manager.delta)) m")
                .foregroundColor(Color("AccentFontColor"))
                .font(.title2)
                .fontWeight(.semibold)
            
            Landmarks()
            
            SearchButton()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.horizontal)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                manager.isDiscovering = true
            }
        }
    }
}

struct DirectionView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionView()
            .environmentObject(LocationManager())
    }
}
