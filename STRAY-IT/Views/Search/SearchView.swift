//
//  SearchView.swift
//  STRAY-IT
//
//  Created by Kanta Oikawa on 2022/12/13.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var viewStates: ViewStates
    @EnvironmentObject var manager: LocationManager
    @State var searcher = LocationSearcher()
    @State private var queryText: String = ""
    @FocusState private var searchBarIsFocused: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(Color("AccentColor"))
                HStack {
                    Image("SearchSmall")
                    TextField("", text: $queryText)
                        .accentColor(Color("Background"))
                        .focused($searchBarIsFocused)
                }
                .foregroundColor(Color("Background"))
                .padding(.leading, 12)
            }
            .frame(height: 40)
            .cornerRadius(24)
            .padding()
            
            ScrollView {
                if ($searcher.wrappedValue.isSearching()) {
                    ProgressView()
                } else {
                    ForEach(searcher.results, id: \.self) { result in
                        Button (action: {
                            searchBarIsFocused = false
                            
                            let coordinate = searcher.getLocationCoordinate(result)
                            let title = searcher.getLocationName(result)
                            manager.setDestination(IdentifiablePlace(latitude: coordinate.latitude, longitude: coordinate.longitude, title: title ?? ""))
                            
                            viewStates.searchViewIsShowing = false
                        }) {
                            HStack {
                                VStack {
                                    HStack {
                                        Text(searcher.getLocationName(result) ?? "")
                                        Spacer()
                                    }
                                    .padding(.vertical, 2.0)
                                }
                                .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .foregroundColor(Color("AccentColor"))
                        }
                        .padding(.top, 8.0)
                        .padding(.bottom, 2.0)
                        .padding(.horizontal, 32.0)
                        
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                manager.isDiscovering = false
                searchBarIsFocused = true
            }
        }
        .onChange(of: queryText, perform: { newValue in
            searcher.setRegion(manager.region)
            searcher.updateQueryText(newValue)
        })
        .onSubmit {
            searchBarIsFocused = false
        }
        .background(Color("Background"))
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(ViewStates())
            .environmentObject(LocationManager())
    }
}
