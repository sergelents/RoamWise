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
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    func setupInitialLocation() {
        LocationManager.shared.requestAuthorization()
        if let userLocation = LocationManager.shared.userLocation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        }
    }
    
    func moveToLocation(_ coordinates: CLLocationCoordinate2D) {
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
    
    func recenterToUserLocation() {
        guard let userLocation = LocationManager.shared.userLocation else {
            LocationManager.shared.requestAuthorization()
            return
        }
        
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
}
