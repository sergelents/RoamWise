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
    @State private var showReviewsForPlace: PlaceAnnotation?
    @State private var showReviewTooltip = false
    @State private var hasShownTooltip = false
    
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
            
            // Dimming overlay when tooltip is shown
            if showReviewTooltip && mapViewModel.annotations.isEmpty {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showReviewTooltip = false
                        }
                    }
            }
            
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    SearchBarView(
                        text: $searchViewModel.searchText,
                        isActive: $searchViewModel.showResults,
                        onTextChange: searchViewModel.updateSearchText,
                        onSubmit: performSearch
                    )
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .allowsHitTesting(true)
                    .zIndex(1)
                    
                    // Review tooltip modal near search bar
                    if showReviewTooltip && mapViewModel.annotations.isEmpty {
                        HStack {
                            Spacer()
                            ReviewTooltipView(onDismiss: {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    showReviewTooltip = false
                                }
                            })
                            .padding(.top, 70)
                            .padding(.trailing, 16)
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))
                        .zIndex(2)
                    }
                }
                
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
            
            // Floating Action Buttons
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    
                    FloatingActionButtons(
                        annotations: mapViewModel.annotations,
                        selectedPlace: mapViewModel.selectedPlace,
                        onLocationTap: {
                            mapViewModel.recenterToUserLocation()
                        },
                        onAddReviewTap: { place in
                            showReviewTooltip = false
                            navigationPath.append(place)
                        }
                    )
                    .padding(.trailing, 24)
                }
                .padding(.bottom, 120)
            }
        }
            .navigationDestination(for: PlaceAnnotation.self) { place in
                AddReviewView(place: place)
            }
            .onChange(of: showReviewsForPlace) { oldValue, newValue in
                if let place = newValue {
                    navigationPath.append(ReviewDestination.reviews(place))
                    showReviewsForPlace = nil
                }
            }
            .navigationDestination(for: ReviewDestination.self) { destination in
                switch destination {
                case .reviews(let place):
                    ReviewsView(place: place)
                }
            }
        }
            .sheet(isPresented: $showLocationDetail) {
                if let place = mapViewModel.selectedPlace {
                    LocationDetailView(
                        place: place,
                        isPresented: $showLocationDetail,
                        onViewReviews: {
                            showReviewsForPlace = place
                        }
                    )
                    .presentationDetents([.height(420)])
                    .presentationDragIndicator(.hidden)
                }
            }
            .task {
                // Async initialization - doesn't block UI rendering
                mapViewModel.setupInitialLocation()
                
                // Show tooltip 1 second after screen loads
                try? await Task.sleep(for: .seconds(1))
                if !hasShownTooltip && mapViewModel.annotations.isEmpty {
                    await MainActor.run {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showReviewTooltip = true
                            hasShownTooltip = true
                        }
                    }
                }
            }
            .onChange(of: mapViewModel.annotations) { oldValue, newValue in
                // Hide tooltip once user has picked a location
                if !newValue.isEmpty && showReviewTooltip {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showReviewTooltip = false
                    }
                }
            }
    }
    
    private func selectLocation(_ suggestion: SearchSuggestion) {
        // Smoothly hide search results
        withAnimation(.easeOut(duration: 0.2)) {
            searchViewModel.clearResults()
        }
        
        searchViewModel.searchText = suggestion.title
        dismissKeyboard()
        
        // Use async/await for better performance on iOS 17.6
        Task { @MainActor in
            if let coordinates = suggestion.coordinates {
                mapViewModel.moveToLocation(
                    coordinates,
                    title: suggestion.title,
                    subtitle: suggestion.subtitle
                )
            } else {
                if let coordinates = await searchViewModel.getCoordinates(for: suggestion) {
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
        
        // Use async/await for better performance
        Task { @MainActor in
            if let coordinates = await searchViewModel.performDetailedSearch(searchText) {
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

// MARK: - Navigation Destinations
enum ReviewDestination: Hashable {
    case reviews(PlaceAnnotation)
}

#Preview {
    HomeView()
}

