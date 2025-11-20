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
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var selectedPlace: PlaceAnnotation?
    @Published var annotations: [PlaceAnnotation] = []
    private var locationUpdateTask: Task<Void, Never>?
    
    init() {
        // Request location immediately
        LocationManager.shared.requestAuthorization()
    }
    
    func setupInitialLocation() {
        // Try multiple times to get location
        locationUpdateTask = Task {
            for attempt in 0..<5 {
                if let userLocation = LocationManager.shared.userLocation {
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 1.0)) {
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
                try? await Task.sleep(for: .milliseconds(500))
            }
            
            // Fallback to San Francisco if location not available
            await MainActor.run {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
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
