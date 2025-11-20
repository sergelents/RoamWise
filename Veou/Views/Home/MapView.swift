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
            // User location with blue dot and pulsing animation
            // This will automatically show when location is available
            UserAnnotation()
            
            // Add place annotations - optimized for iOS 17.6
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
        .mapControls {
            // Enable user location button (this also helps show the blue dot)
            MapUserLocationButton()
        }
//        .safeAreaInset(edge: .top, alignment: .trailing) {
//            // Zoom controls in top right (Google Maps style)
//            VStack(spacing: 0) {
//                ZoomButton(icon: "plus", action: zoomIn)
//                Divider()
//                    .frame(width: 44)
//                    .background(Color.gray.opacity(0.3))
//                ZoomButton(icon: "minus", action: zoomOut)
//            }
//            .background(.ultraThinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
//            .padding(.trailing, 16)
//            .padding(.top, 8)
//        }
    }
    
//    private func zoomIn() {
//        // Get current region and zoom in
//        if case .region(let region) = cameraPosition {
//            let newSpan = MKCoordinateSpan(
//                latitudeDelta: region.span.latitudeDelta * 0.5,
//                longitudeDelta: region.span.longitudeDelta * 0.5
//            )
//            withAnimation(.easeInOut(duration: 0.3)) {
//                cameraPosition = .region(MKCoordinateRegion(center: region.center, span: newSpan))
//            }
//        }
//    }
    
//    private func zoomOut() {
//        // Get current region and zoom out
//        if case .region(let region) = cameraPosition {
//            let newSpan = MKCoordinateSpan(
//                latitudeDelta: min(region.span.latitudeDelta * 2.0, 180.0),
//                longitudeDelta: min(region.span.longitudeDelta * 2.0, 180.0)
//            )
//            withAnimation(.easeInOut(duration: 0.3)) {
//                cameraPosition = .region(MKCoordinateRegion(center: region.center, span: newSpan))
//            }
//        }
//    }
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
                .transition(.scale.combined(with: .opacity))
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
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Zoom Button
struct ZoomButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(ZoomButtonStyle())
    }
}

struct ZoomButtonStyle: ButtonStyle {
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
