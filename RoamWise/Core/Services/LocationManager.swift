import Foundation
import CoreLocation
import SwiftUI

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private var lastLocation: CLLocation?
    
    var userLocation: CLLocationCoordinate2D? {
        lastLocation?.coordinate ?? locationManager.location?.coordinate
    }
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
    func requestAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            #if os(iOS)
            locationManager.requestWhenInUseAuthorization()
            #elseif os(macOS)
            locationManager.requestAlwaysAuthorization()
            #endif
        case .denied, .restricted:
            print("Location access denied. Please enable in Settings.")
        default:
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            #if os(iOS)
            if manager.authorizationStatus == .authorizedWhenInUse || 
               manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
            #elseif os(macOS)
            if manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
            #endif
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.lastLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
} 