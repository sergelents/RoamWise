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
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
            
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Use selected place if available, otherwise use the most recent annotation
                            let placeToReview = mapViewModel.selectedPlace ?? mapViewModel.annotations.last
                            if let place = placeToReview {
                                navigationPath.append(place)
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color(red: 1.0, green: 0.42, blue: 0.42))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .opacity(!mapViewModel.annotations.isEmpty ? 1.0 : 0.5)
                        .disabled(mapViewModel.annotations.isEmpty)
                        .padding(.trailing, 24)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationDestination(for: PlaceAnnotation.self) { place in
                AddReviewView(place: place)
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

