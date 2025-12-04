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
            
            // Add place annotations with simple clean pin
            ForEach(annotations) { place in
                Annotation("", coordinate: place.coordinate) {
                    VStack(spacing: 4) {
                        // Safety rating overlay for selected pins
                        if selectedPlace?.id == place.id {
                            SafetyRatingOverlay(place: place)
                                .offset(y: -8)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Simple clean pin
                        SimplePin(isSelected: selectedPlace?.id == place.id)
                            .onTapGesture {
                                onPinTapped?(place)
                            }
                        
                        // Location name below pin
                        Text(place.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .offset(y: 4)
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

// MARK: - Simple Clean Pin
struct SimplePin: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .fill(isSelected ? Color.red : Color(red: 0.2, green: 0.6, blue: 0.9))
                .frame(width: 32, height: 32)
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
            
            // Inner white circle
            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
        }
    }
}

// MARK: - Safety Rating Overlay
struct SafetyRatingOverlay: View {
    let place: PlaceAnnotation
    
    var body: some View {
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
