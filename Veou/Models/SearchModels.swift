//
//  SearchModels.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import Foundation
import CoreLocation
import MapKit

// MARK: - Search Data Models
struct SearchSuggestion: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let coordinates: CLLocationCoordinate2D?
    let isPopular: Bool
    let distance: Double? // Distance from user in meters
}

// MARK: - Place Annotation
struct PlaceAnnotation: Identifiable, Equatable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
    let rating: Double
    let reviewCount: Int
    let crowdLevel: CrowdLevel
    let distance: Double? // Distance from user in miles
    
    enum CrowdLevel: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var icon: String {
            switch self {
            case .low: return "person"
            case .medium: return "person.2"
            case .high: return "person.3"
            }
        }
    }
    
    // Custom Equatable implementation
    static func == (lhs: PlaceAnnotation, rhs: PlaceAnnotation) -> Bool {
        lhs.id == rhs.id
    }
    
    // Custom Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension PlaceAnnotation {
    // Mock data for demonstration
    static func mock(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) -> PlaceAnnotation {
        PlaceAnnotation(
            coordinate: coordinate,
            title: title,
            subtitle: subtitle,
            rating: Double.random(in: 3.5...5.0),
            reviewCount: Int.random(in: 50...500),
            crowdLevel: CrowdLevel.allCases.randomElement() ?? .medium,
            distance: Double.random(in: 0.1...5.0)
        )
    }
}

extension PlaceAnnotation.CrowdLevel: CaseIterable {} 