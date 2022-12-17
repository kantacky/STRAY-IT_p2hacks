//
//  AdventureView.swift
//  STRAY-IT
//
//  Created by Kanta Oikawa on 2022/12/17.
//

import SwiftUI

struct AdventureView: View {
    @EnvironmentObject var manager: LocationManager
    
    var body: some View {
        UIMapView()
            .edgesIgnoringSafeArea([.top, .horizontal])
    }
}

struct AdventureView_Previews: PreviewProvider {
    static var previews: some View {
        AdventureView()
            .environmentObject(LocationManager())
    }
}
