import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Binding var cameraPosition: MapCameraPosition
    var annotations: [PlaceAnnotation]
    var selectedPlace: PlaceAnnotation?
    var onPinTapped: ((PlaceAnnotation) -> Void)?
    
    var body: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            UserAnnotation()
            
            // Add place annotations
            ForEach(annotations) { place in
                Annotation("", coordinate: place.coordinate) {
                    PinAnnotationView(
                        place: place,
                        isSelected: selectedPlace?.id == place.id
                    )
                    .onTapGesture {
                        onPinTapped?(place)
                    }
                }
            }
        }
        .mapStyle(.standard)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                MapControls(cameraPosition: $cameraPosition)
                    .padding(.trailing)
            }
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Pin Annotation View
struct PinAnnotationView: View {
    let place: PlaceAnnotation
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Rating overlay (only shown for selected pin)
            if isSelected {
                HStack(spacing: 4) {
                    Text(String(format: "%.1f", place.rating))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                .offset(y: -8)
            }
            
            // Pin marker
            ZStack {
                // Pin shape
                Circle()
                    .fill(isSelected ? Color.orange : Color.green)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Inner circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
            }
        }
    }
}

// MARK: - Map Controls
struct MapControls: View {
    @Binding var cameraPosition: MapCameraPosition
    
    var body: some View {
        VStack(spacing: 0) {
            MapControlButton(icon: "plus", action: {})
            Divider().background(Color.gray.opacity(0.3)).frame(width: 30)
            MapControlButton(icon: "location", action: recenterToUserLocation)
            Divider().background(Color.gray.opacity(0.3)).frame(width: 30)
            MapControlButton(icon: "minus", action: {})
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    private func recenterToUserLocation() {
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

struct MapControlButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(MapControlButtonStyle())
    }
}

struct MapControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    MapView(
        cameraPosition: .constant(.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )),
        annotations: [],
        selectedPlace: nil
    )
}
