//
//  HomeView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(
                cameraPosition: $mapViewModel.cameraPosition,
                onMapTapped: searchViewModel.hideSearch
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                SearchBarView(
                    text: $searchViewModel.searchText,
                    isActive: $searchViewModel.showResults,
                    onTextChange: searchViewModel.updateSearchText,
                    onSubmit: performSearch
                )
                .padding(.horizontal)
                .padding(.top, 10)
                
                if searchViewModel.showResults && !searchViewModel.suggestions.isEmpty {
                    SearchResultsView(
                        suggestions: searchViewModel.suggestions,
                        onSelect: selectLocation
                    )
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                Spacer()
                TabBarView(selectedTab: .constant(0))
            }
        }
        .onAppear {
            mapViewModel.setupInitialLocation()
        }
    }
    
    private func selectLocation(_ suggestion: SearchSuggestion) {
        withAnimation(.easeOut(duration: 0.1)) {
            searchViewModel.clearResults()
        }
        
        searchViewModel.searchText = suggestion.title
        dismissKeyboard()
        
        if let coordinates = suggestion.coordinates {
            mapViewModel.moveToLocation(coordinates)
        } else {
            searchViewModel.getCoordinates(for: suggestion) { coordinates in
                if let coordinates = coordinates {
                    mapViewModel.moveToLocation(coordinates)
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchViewModel.searchText.isEmpty else { return }
        searchViewModel.performDetailedSearch(searchViewModel.searchText) { coordinates in
            if let coordinates = coordinates {
                mapViewModel.moveToLocation(coordinates)
            }
        }
    }
    
    private func dismissKeyboard() {
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

#Preview {
    HomeView()
}

