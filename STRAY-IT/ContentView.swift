//
//  ContentView.swift
//  STRAY-IT
//
//  Created by Kanta Oikawa on 2022/12/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DirectionView()
                .tabItem {
                    Image(systemName: "location.north.line")
                    Text("Direction")
                }
            
//            AdventureView()
//                .tabItem {
//                    Image(systemName: "figure.walk")
//                    Text("Adventure")
//                }
//
//            CheatView()
//                .tabItem {
//                    Image(systemName: "map")
//                    Text("Cheat")
//                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationManager())
    }
}
