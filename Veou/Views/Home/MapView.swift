import SwiftUI
import MapKit

struct MapView: View {
    @Binding var cameraPosition: MapCameraPosition
    @State private var mapStyle: MapStyle = .standard
    @State private var selectedPlace: MKMapItem?
    @State private var showPlacesSheet = false
    @StateObject private var viewModel = MapViewModel()
    
    // Optional closure to handle map taps
    var onMapTapped: (() -> Void)?
    
    var body: some View {
        ZStack {
            // The main map
            Map(position: $cameraPosition, interactionModes: .all, selection: $selectedPlace) {
                // User location annotation
                UserAnnotation()
                
                // Display popular nearby places if viewModel has places
                ForEach(viewModel.popularPlaces, id: \.self) { place in
                    if let placeName = place.name {
                        Marker(placeName, coordinate: place.placemark.coordinate)
                            .tint(.blue)
                    }
                }
            }
            .mapStyle(mapStyle)
            .onAppear {
                // Request location authorization and fetch popular places when map appears
                LocationManager.shared.requestAuthorization()
                
                // Delay fetching to ensure location is available
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Task {
                        await viewModel.fetchPopularNearbyPlaces(clearPrevious: true)
                    }
                }
            }
            .onChange(of: cameraPosition) { _, _ in
                // When camera position changes significantly, update popular places
                Task {
                    await viewModel.debouncedFetchPopularPlaces(clearPrevious: true)
                }
            }
            
            // Transparent overlay to capture taps but allow map interactions to pass through
            Color.clear
                .contentShape(Rectangle())
                .allowsHitTesting(true)
                .onTapGesture {
                    onMapTapped?()
                }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                // Map control buttons (zoom in/out, recenter)
                VStack(spacing: 0) {
                    // Zoom in button
                    MapControlButton(icon: "plus") {
//                        zoomIn()
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .frame(width: 30)
                    
                    // Recenter button
                    MapControlButton(icon: "location") {
                        recenterToUserLocation()
                    }
                    .background(.ultraThinMaterial)
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .frame(width: 30)
                    
                    // Zoom out button
                    MapControlButton(icon: "minus") {
//                        zoomOut()
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                .padding(.trailing)
            }
            .padding(.bottom, 100) // Allow space for the tab bar
        }
    }
    
    // Zoom in function
//    private func zoomIn() {
//        withAnimation {
//            switch cameraPosition {
//            case .region(let region):
//                let newSpan = MKCoordinateSpan(
//                    latitudeDelta: max(region.span.latitudeDelta * 0.5, 0.001),
//                    longitudeDelta: max(region.span.longitudeDelta * 0.5, 0.001)
//                )
//                cameraPosition = .region(
//                    MKCoordinateRegion(center: region.center, span: newSpan)
//                )
//            default:
//                break
//            }
//        }
//    }
    
    // Zoom out function
//    private func zoomOut() {
//        withAnimation {
//            switch cameraPosition {
//            case .region(let region):
//                let newSpan = MKCoordinateSpan(
//                    latitudeDelta: min(region.span.latitudeDelta * 2.0, 180.0),
//                    longitudeDelta: min(region.span.longitudeDelta * 2.0, 180.0)
//                )
//                cameraPosition = .region(
//                    MKCoordinateRegion(center: region.center, span: newSpan)
//                )
//            default:
//                break
//            }
//        }
//    }
    
    // Recenter to user location
    private func recenterToUserLocation() {
        if let userLocation = LocationManager.shared.userLocation {
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
            // Reset search when centering on user location
            viewModel.clearSearchResults()
        } else {
            // Handle case when location is not available
            print("User location not available")
            LocationManager.shared.requestAuthorization()
        }
    }
}

// Reusable control button for map
struct MapControlButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(MapControlButtonStyle())
    }
}

// Custom button style for map controls
struct MapControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}


// Location Manager to handle permissions and track user location
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private(set) var locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var lastLocation: CLLocation?
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10 // Update when user moves 10 meters
        self.locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestAuthorization() {
        // Check current status before requesting
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .denied ||
                  locationManager.authorizationStatus == .restricted {
            // Handle case where user has denied location access
            print("Location access denied. Please enable in Settings.")
        } else {
            // We already have permission, start updating
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.lastLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    var userLocation: CLLocationCoordinate2D? {
        return lastLocation?.coordinate ?? locationManager.location?.coordinate
    }
}

#Preview {
    MapView(cameraPosition: .constant(.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )))
}
