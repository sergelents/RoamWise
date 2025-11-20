//
//  HomeView.swift
//  Veou
//
//  Created by Serg sTsogtbaatar on 4/10/25.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var showLocationDetail = false
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(
                cameraPosition: $mapViewModel.cameraPosition,
                annotations: mapViewModel.annotations,
                selectedPlace: mapViewModel.selectedPlace,
                onPinTapped: { place in
                    mapViewModel.selectPlace(place)
                    showLocationDetail = true
                }
            )
            .ignoresSafeArea()
            .onChange(of: mapViewModel.selectedPlace) { oldValue, newValue in
                if newValue != nil {
                    showLocationDetail = true
                }
            }
            .onChange(of: showLocationDetail) { oldValue, newValue in
                if !newValue {
                    mapViewModel.deselectPlace()
                }
            }
            
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
        .sheet(isPresented: $showLocationDetail) {
            if let place = mapViewModel.selectedPlace {
                LocationDetailView(place: place, isPresented: $showLocationDetail)
                    .presentationDetents([.height(420)])
                    .presentationDragIndicator(.hidden)
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
            mapViewModel.moveToLocation(
                coordinates,
                title: suggestion.title,
                subtitle: suggestion.subtitle
            )
        } else {
            searchViewModel.getCoordinates(for: suggestion) { coordinates in
                if let coordinates = coordinates {
                    mapViewModel.moveToLocation(
                        coordinates,
                        title: suggestion.title,
                        subtitle: suggestion.subtitle
                    )
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchViewModel.searchText.isEmpty else { return }
        let searchText = searchViewModel.searchText
        searchViewModel.performDetailedSearch(searchText) { coordinates in
            if let coordinates = coordinates {
                mapViewModel.moveToLocation(
                    coordinates,
                    title: searchText,
                    subtitle: ""
                )
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

