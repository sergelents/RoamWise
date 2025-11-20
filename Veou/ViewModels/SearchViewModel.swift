import Foundation
import SwiftUI
import MapKit
import CoreLocation

// MARK: - Search ViewModel
@MainActor
class SearchViewModel: NSObject, ObservableObject {
    @Published var suggestions: [SearchSuggestion] = []
    @Published var searchText = ""
    @Published var showResults = false
    @Published var popularNearbyPlaces: [SearchSuggestion] = []
    
    private let completer = MKLocalSearchCompleter()
    private let popularCategories: Set<String> = [
        "restaurant", "café", "coffee", "bar", "pub", "park", "theater", "cinema", 
        "mall", "shopping", "museum", "hotel", "gym", "pharmacy", "hospital", 
        "gas station", "bank", "atm", "grocery", "supermarket"
    ]
    
    private var searchTask: Task<Void, Never>?
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
        setupCompleterRegion()
        fetchPopularNearbyPlaces()
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
        showResults = !text.isEmpty
        
        // Cancel previous search task to prevent jank
        searchTask?.cancel()
        
        // Debounce search for better performance
        searchTask = Task { @MainActor in
            // Small delay to debounce rapid typing
            try? await Task.sleep(for: .milliseconds(150))
            
            guard !Task.isCancelled else { return }
            
            if text.isEmpty {
                // Show popular nearby places when search is empty
                suggestions = popularNearbyPlaces
            } else if text.count <= 2 {
                // Show popular places immediately for 1-2 characters
                let filteredPopular = popularNearbyPlaces.filter { place in
                    place.title.localizedCaseInsensitiveContains(text) ||
                    place.subtitle.localizedCaseInsensitiveContains(text)
                }
                suggestions = filteredPopular.isEmpty ? popularNearbyPlaces : filteredPopular
            } else {
                // For longer queries, use normal search with popular places mixed in
                updateQuery(text)
            }
        }
    }
    
    func updateQuery(_ query: String) {
        completer.queryFragment = query
    }
    
    func clearResults() {
        suggestions = []
        showResults = false
    }
    
    func hideSearch() {
        searchText = ""
        showResults = false
        clearResults()
    }
    
    func fetchPopularNearbyPlaces() {
        guard let userLocation = LocationManager.shared.userLocation else {
            return
        }
        
        searchTask = Task {
            var allPopularPlaces: [SearchSuggestion] = []
            
            // Search for multiple popular categories
            let categories = ["restaurant", "café", "park", "shopping", "museum", "theater"]
            
            for category in categories {
                if Task.isCancelled { break }
                
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = category
                request.region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                
                let search = MKLocalSearch(request: request)
                
                do {
                    let response = try await search.start()
                    let places = response.mapItems.prefix(5).compactMap { item -> SearchSuggestion? in
                        guard let name = item.name,
                              let location = item.placemark.location else { return nil }
                        
                        let distance = location.distance(from: CLLocation(
                            latitude: userLocation.latitude,
                            longitude: userLocation.longitude
                        ))
                        
                        // Only include places within 10km
                        guard distance <= 10000 else { return nil }
                        
                        return SearchSuggestion(
                            id: "\(name)-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                            title: name,
                            subtitle: item.placemark.title ?? "",
                            coordinates: item.placemark.coordinate,
                            isPopular: true,
                            distance: distance
                        )
                    }
                    
                    allPopularPlaces.append(contentsOf: places)
                } catch {
                    print("Error fetching \(category): \(error)")
                }
                
                // Small delay between requests to avoid overwhelming the API
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            
            if !Task.isCancelled {
                // Remove duplicates and sort by distance
                let uniquePlaces = Dictionary(grouping: allPopularPlaces) { $0.title }
                    .compactMapValues { $0.first }
                    .values
                    .sorted { ($0.distance ?? Double.greatestFiniteMagnitude) < ($1.distance ?? Double.greatestFiniteMagnitude) }
                
                await MainActor.run {
                    self.popularNearbyPlaces = Array(uniquePlaces.prefix(15))
                    
                    // If search is empty, show popular places
                    if self.searchText.isEmpty && self.showResults {
                        self.suggestions = self.popularNearbyPlaces
                    }
                }
            }
        }
    }
    
    func getCoordinates(for suggestion: SearchSuggestion, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        // If we already have coordinates, use them immediately
        if let coordinates = suggestion.coordinates {
            Task { @MainActor in
                completion(coordinates)
            }
            return
        }
        
        // Use async/await for better performance on iOS 17.6
        Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "\(suggestion.title), \(suggestion.subtitle)"
            
            if let userLocation = LocationManager.shared.userLocation {
                request.region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
            
            let search = MKLocalSearch(request: request)
            
            do {
                let response = try await search.start()
                await MainActor.run {
                    completion(response.mapItems.first?.placemark.coordinate)
                }
            } catch {
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }
    
    func performDetailedSearch(_ query: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        // Use async/await for better performance on iOS 17.6
        Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            if let userLocation = LocationManager.shared.userLocation {
                request.region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
            
            let search = MKLocalSearch(request: request)
            
            do {
                let response = try await search.start()
                await MainActor.run {
                    completion(response.mapItems.first?.placemark.coordinate)
                }
            } catch {
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }
    
    private func setupCompleterRegion() {
        if let userLocation = LocationManager.shared.userLocation {
            completer.region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
    }
    
    private func isPopular(_ completion: MKLocalSearchCompletion) -> Bool {
        let searchText = "\(completion.title) \(completion.subtitle)".lowercased()
        return popularCategories.contains { category in
            searchText.contains(category)
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension SearchViewModel: @preconcurrency MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let searchResults = completer.results.prefix(6).map { completion in
            SearchSuggestion(
                id: completion.title + completion.subtitle,
                title: completion.title,
                subtitle: completion.subtitle,
                coordinates: nil,
                isPopular: isPopular(completion),
                distance: nil
            )
        }
        
        // Combine search results with popular nearby places
        var combinedResults: [SearchSuggestion] = []
        
        // Add popular nearby places that match the search
        if !searchText.isEmpty {
            let matchingPopular = popularNearbyPlaces.filter { place in
                place.title.localizedCaseInsensitiveContains(searchText) ||
                place.subtitle.localizedCaseInsensitiveContains(searchText)
            }.prefix(3)
            combinedResults.append(contentsOf: matchingPopular)
        }
        
        // Add search results
        combinedResults.append(contentsOf: searchResults)
        
        // Remove duplicates based on title
        let uniqueResults = Dictionary(grouping: combinedResults) { $0.title.lowercased() }
            .compactMapValues { $0.first }
            .values
        
        // Sort: popular nearby first, then by relevance
        suggestions = uniqueResults.sorted { lhs, rhs in
            if lhs.isPopular && lhs.distance != nil && !rhs.isPopular {
                return true
            } else if !lhs.isPopular && rhs.isPopular && rhs.distance != nil {
                return false
            } else if lhs.isPopular && rhs.isPopular {
                return (lhs.distance ?? Double.greatestFiniteMagnitude) < (rhs.distance ?? Double.greatestFiniteMagnitude)
            } else {
                return false
            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
} 