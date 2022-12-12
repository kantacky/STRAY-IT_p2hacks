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
        VStack {
            Image("Direction")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
                .rotationEffect(.degrees(manager.destinationDirection))
            
            Text("あと \(Int(manager.delta)) m")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.horizontal)
    }
}

struct DirectionView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionView()
            .environmentObject(LocationManager())
    }
}
