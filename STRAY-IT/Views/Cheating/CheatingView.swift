//
//  CheatingView.swift
//  STRAY-IT
//
//  Created by inoue mei on 2022/12/17.
//

import SwiftUI

struct CheatingView: View {
    @EnvironmentObject var manager: LocationManager
    
    var body: some View {
        UIMapView()
            .edgesIgnoringSafeArea([.top, .horizontal])
    }
}

struct CheatingView_Previews: PreviewProvider {
    static var previews: some View {
        CheatingView()
            .environmentObject(LocationManager())
    }
}
