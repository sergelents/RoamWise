//
//  MapViewModel.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

@MainActor
class MapViewModel: ObservableObject {
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    ))
    @Published var selectedPlace: PlaceAnnotation?
    @Published var annotations: [PlaceAnnotation] = []
    private var locationUpdateTask: Task<Void, Never>?
    
    init() {
        // Don't request location in init - defer to setupInitialLocation
    }
    
    func setupInitialLocation() {
        // Don't request authorization here - only request when user explicitly taps "Allow Location Access"
        // Just use location if it's already available
        
        // Start with user location, then refine after a moment
        locationUpdateTask = Task {
            // Wait for location to become available (reduced attempts for faster startup)
            for attempt in 0..<5 {
                if let userLocation = LocationManager.shared.userLocation {
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: userLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                )
                            )
                        }
                    }
                    return
                }
                try? await Task.sleep(for: .milliseconds(400))
            }
            
            // If still no location, keep the fallback region
            // The UserAnnotation will still show if location becomes available later
        }
    }
    
    func moveToLocation(_ coordinates: CLLocationCoordinate2D, title: String = "", subtitle: String = "") {
        // Add annotation first (non-animated)
        let annotation = PlaceAnnotation.mock(
            coordinate: coordinates,
            title: title,
            subtitle: subtitle
        )
        
        // Remove any existing annotation with same coordinates to avoid duplicates
        annotations.removeAll { $0.coordinate.latitude == coordinates.latitude && $0.coordinate.longitude == coordinates.longitude }
        annotations.append(annotation)
        
        // Animate camera movement smoothly
        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
    
    func selectPlace(_ place: PlaceAnnotation) {
        selectedPlace = place
    }
    
    func deselectPlace() {
        selectedPlace = nil
    }
    
    func recenterToUserLocation() {
        guard let userLocation = LocationManager.shared.userLocation else {
            LocationManager.shared.requestAuthorization()
            return
        }
        
        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
    
    deinit {
        locationUpdateTask?.cancel()
    }
}
