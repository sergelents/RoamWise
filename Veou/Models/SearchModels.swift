//
//  SearchModels.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import Foundation
import CoreLocation

// MARK: - Search Data Models
struct SearchSuggestion: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let coordinates: CLLocationCoordinate2D?
    let isPopular: Bool
    let distance: Double? // Distance from user in meters
} 