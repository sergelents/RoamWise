//
//  HomeView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI
import MapKit
import Combine

struct HomeView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [LocationResult] = []
    @State private var selectedTab = 0
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    // For managing location search
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var searchCompleter = LocationSearchCompleter()
    
    var body: some View {
        ZStack(alignment: .top) {
            // Map View with tap handling
            MapView(cameraPosition: $cameraPosition, onMapTapped: {
                resetToInitialState()
            })
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(
                    searchText: $searchText,
                    isSearching: $isSearching,
                    onSearch: performSearch
                )
                .padding(.horizontal)
                .padding(.top, 10)
                .onChange(of: searchText) { _, newValue in
                    if !newValue.isEmpty {
                        isSearching = true
                        searchCompleter.searchQuery = newValue
                    } else {
                        isSearching = false
                        searchResults = []
                    }
                }
                
                // Search Results (when searching)
                if isSearching && (!searchCompleter.results.isEmpty || !searchResults.isEmpty) {
                    SearchResultsView(
                        results: getDisplayResults(),
                        onSelectLocation: { location in
                            // Immediately hide search results before handling location
                            withAnimation(.easeOut(duration: 0.1)) {
                                isSearching = false
                                // Clear the completer results immediately
                                searchCompleter.clearResults()
                            }
                            handleLocationSelection(location)
                        }
                    )
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                Spacer()
                
                // Bottom Tab Bar
                TabBarView(selectedTab: $selectedTab)
            }
        }
        .onAppear {
            // Request location permissions when view appears
            locationManager.requestAuthorization()
            
            // Set initial camera position to user location if available
            if let userLocation = locationManager.userLocation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
        }
    }
    
    // Reset to initial state - clear search and dismiss results
    private func resetToInitialState() {
        // Only perform reset if user is searching
        if isSearching {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            withAnimation(.easeOut(duration: 0.2)) {
                searchText = ""
                isSearching = false
                searchResults = []
                
                // Clear completer results
                searchCompleter.searchQuery = ""
                searchCompleter.clearResults()
            }
        }
    }
    
    // Combine autocomplete results and search results
    private func getDisplayResults() -> [LocationResult] {
        var combinedResults: [LocationResult] = []
        
        // Add autocomplete results for nearby popular places first
        if !searchCompleter.results.isEmpty {
            let autoCompleteResults = searchCompleter.results.prefix(5).map { suggestion in
                return LocationResult(
                    id: suggestion.title + suggestion.subtitle,
                    name: suggestion.title,
                    address: suggestion.subtitle,
                    coordinates: nil,
                    isPopular: suggestion.subtitle.contains("Popular") ||
                              suggestion.subtitle.contains("Nearby") ||
                              searchCompleter.isPopularPOI(suggestion)
                )
            }
            combinedResults.append(contentsOf: autoCompleteResults)
        }
        
        // Add search results
        if !searchResults.isEmpty {
            combinedResults.append(contentsOf: searchResults)
        }
        
        return combinedResults
    }
    
    // Handle location selection from search results
    func handleLocationSelection(_ location: LocationResult) {
        // Set the search text to the selected location's name
        searchText = location.name
        
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // If we have coordinates, move the map there
        if let coordinates = location.coordinates {
            moveMapTo(coordinates)
        } else {
            // If we don't have coordinates yet (from autocomplete), look them up
            searchLocationDetails(for: location.name + ", " + location.address)
        }
    }
    
    // Move map to specified coordinates
    private func moveMapTo(_ coordinates: CLLocationCoordinate2D) {
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
    
    // Perform a full search
    private func performSearch() {
        if !searchText.isEmpty {
            searchLocationDetails(for: searchText)
        }
    }
    
    // Look up detailed location information including coordinates
    private func searchLocationDetails(for query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        
        // Use a region centered on user's location for more relevant results
        if let userLocation = locationManager.userLocation {
            searchRequest.region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, error == nil else {
                return
            }
            
            let results = response.mapItems.map { item -> LocationResult in
                // Check if this is a point of interest - POIs are usually more popular/established locations
                let isPOI = item.pointOfInterestCategory != nil
                
                // Determine if this is likely a popular location
                let isPopularLocation = isPOI ||
                                       (item.placemark.areasOfInterest?.count ?? 0 > 0) ||
                                       (item.name?.contains("Park") ?? false) ||
                                       (item.name?.contains("Restaurant") ?? false) ||
                                       (item.name?.contains("Café") ?? false) ||
                                       (item.name?.contains("Mall") ?? false)
                
                // Format the address
                let address = formatAddress(from: item.placemark)
                
                return LocationResult(
                    id: item.name ?? UUID().uuidString,
                    name: item.name ?? "Unknown Location",
                    address: address,
                    coordinates: item.placemark.coordinate,
                    isPopular: isPopularLocation
                )
            }
            
            DispatchQueue.main.async {
                self.searchResults = results
                
                // If we have exactly one result, use it
                if results.count == 1, let coordinates = results.first?.coordinates {
                    moveMapTo(coordinates)
                }
            }
        }
    }
    
    // Helper to format address from placemark
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        
        if let subThoroughfare = placemark.subThoroughfare {
            // If we already have the thoroughfare, combine them
            if !components.isEmpty {
                components[0] = "\(subThoroughfare) \(components[0])"
            } else {
                components.append(subThoroughfare)
            }
        }
        
        if let locality = placemark.locality {
            components.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea, placemark.locality == nil {
            components.append(administrativeArea)
        }
        
        return components.joined(separator: ", ")
    }
}

// Location search completer for autocomplete suggestions
class LocationSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    private let completer = MKLocalSearchCompleter()
    private let popularCategories: Set<String> = [
        "Restaurant", "Café", "Coffee", "Bar", "Park",
        "Theater", "Cinema", "Mall", "Shop", "Store",
        "Museum", "Hotel", "Stadium", "Airport", "Station"
    ]
    
    @Published var searchQuery = "" {
        didSet {
            completer.queryFragment = searchQuery
        }
    }
    
    @Published var results: [MKLocalSearchCompletion] = []
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
        
        // Prioritize nearby results
        if let userLocation = LocationManager.shared.userLocation {
            completer.region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
    }
    
    // Clear search results
    func clearResults() {
        results = []
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Get diverse results, prioritizing popular locations
        var filteredResults = completer.results
        
        // If we have many results, prioritize popular ones
        if filteredResults.count > 5 {
            // Sort by whether they match popular categories
            filteredResults.sort { a, b in
                let aIsPopular = isPopularPOI(a)
                let bIsPopular = isPopularPOI(b)
                
                if aIsPopular && !bIsPopular {
                    return true
                } else if !aIsPopular && bIsPopular {
                    return false
                }
                
                // If both or neither are popular, sort by whether they have detailed subtitles
                return !a.subtitle.isEmpty && b.subtitle.isEmpty
            }
        }
        
        // Take a limited set to avoid overwhelming the user
        results = Array(filteredResults.prefix(8))
    }
    
    func isPopularPOI(_ completion: MKLocalSearchCompletion) -> Bool {
        // Check if the title contains known popular categories
        for category in popularCategories {
            if completion.title.contains(category) || completion.subtitle.contains(category) {
                return true
            }
        }
        return false
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error in search completer: \(error.localizedDescription)")
    }
}

#Preview {
    HomeView()
}
