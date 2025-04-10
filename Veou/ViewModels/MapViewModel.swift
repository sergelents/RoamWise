//
//  MapViewModel.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import Foundation
import SwiftUI
import MapKit

// ViewModel to handle popular places search
class MapViewModel: ObservableObject {
    @Published var popularPlaces: [MKMapItem] = []
    private var searchTask: Task<Void, Never>?
    private var isSearching = false
    private var searchID = UUID()
    
    // Clear search results
    func clearSearchResults() {
        DispatchQueue.main.async {
            self.popularPlaces = []
        }
    }
    
    // Debounce fetching to avoid too many API calls when panning the map
    func debouncedFetchPopularPlaces(clearPrevious: Bool = false) {
        // Cancel existing search task
        searchTask?.cancel()
        
        // Generate a new search ID
        let newSearchID = UUID()
        searchID = newSearchID
        
        // Clear previous results if requested
        if clearPrevious {
            clearSearchResults()
        }
        
        // Create a new search task
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            
            // Debounce delay
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            if Task.isCancelled { return }
            
            await self.fetchPopularNearbyPlaces(clearPrevious: clearPrevious, searchID: newSearchID)
        }
    }
    
    @MainActor
    func fetchPopularNearbyPlaces(clearPrevious: Bool = false, searchID: UUID? = nil) async {
        // Get current user location or use a default
        guard !isSearching, let userLocation = LocationManager.shared.userLocation else {
            return
        }
        
        // Use provided searchID or generate a new one
        let currentSearchID = searchID ?? UUID()
        self.searchID = currentSearchID
        
        isSearching = true
        
        // Clear previous results if requested
        if clearPrevious {
            self.popularPlaces = []
        }
        
        do {
            // Search for popular places
            let places = try await searchPlaces(near: userLocation, query: "popular places")
            
            // Only update if this is still the current search
            if self.searchID == currentSearchID {
                let sortedPlaces = places.sorted {
                    let aCount = $0.placemark.areasOfInterest?.count ?? 0
                    let bCount = $1.placemark.areasOfInterest?.count ?? 0
                    
                    if aCount != bCount {
                        return aCount > bCount
                    }
                    return ($0.name ?? "") < ($1.name ?? "")
                }
                
                self.popularPlaces = Array(sortedPlaces.prefix(10))
                
                // Search for specific categories
                if self.searchID == currentSearchID {
                    await self.fetchSpecificCategories(near: userLocation, searchID: currentSearchID)
                }
            }
        } catch {
            print("Error fetching popular places: \(error.localizedDescription)")
        }
        
        isSearching = false
    }
    
    private func searchPlaces(near coordinate: CLLocationCoordinate2D, query: String) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.pointOfInterest]
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        return response.mapItems
    }
    
    @MainActor
    private func fetchSpecificCategories(near coordinate: CLLocationCoordinate2D, searchID: UUID) async {
        let categories = ["restaurant", "cafe", "park", "museum", "shopping"]
        
        for category in categories {
            if self.searchID != searchID { return }
            
            do {
                let places = try await searchPlaces(near: coordinate, query: category)
                
                if self.searchID == searchID {
                    let topResults = Array(places.prefix(3))
                    
                    if self.popularPlaces.count < 15 && !topResults.isEmpty {
                        let existingNames = Set(self.popularPlaces.compactMap { $0.name })
                        let newPlaces = topResults.filter { $0.name != nil && !existingNames.contains($0.name!) }
                        
                        self.popularPlaces.append(contentsOf: newPlaces)
                        if self.popularPlaces.count > 15 {
                            self.popularPlaces = Array(self.popularPlaces.prefix(15))
                        }
                    }
                }
            } catch {
                print("Error fetching \(category) places: \(error.localizedDescription)")
            }
        }
    }
}
