//
//  SearchView.swift
//  STRAY-IT
//
//  Created by Kanta Oikawa on 2022/12/13.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var manager: LocationManager
    @State private var queryText: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    LabeledContent("目的地") {
                        Text(manager.start_and_goal[1].title)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $queryText)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(LocationManager())
    }
}
