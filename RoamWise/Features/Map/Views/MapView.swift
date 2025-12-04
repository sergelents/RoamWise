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
                    ZStack {
                        // Simple clean pin (anchored at center)
                        SimplePin(isSelected: selectedPlace?.id == place.id)
                            .onTapGesture {
                                onPinTapped?(place)
                            }
                        
                        // Safety rating overlay for selected pins (positioned above)
                        if selectedPlace?.id == place.id {
                            SafetyRatingOverlay(place: place)
                                .offset(y: -55)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Location name below pin (positioned below)
                        Text(place.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .offset(y: 45)
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

// MARK: - Simple Clean Pin (Teal/Green Design)
struct SimplePin: View {
    let isSelected: Bool
    @State private var hasDropped = false
    @State private var isBouncing = false
    
    // Teal/green color matching design spec
    private let tealColor = Color(red: 0.078, green: 0.722, blue: 0.651) // #14B8A6
    private let tealLighter = Color(red: 0.176, green: 0.831, blue: 0.749) // #2DD4BF
    
    var body: some View {
        ZStack {
            // Pulsing ring
            PulseRing(color: tealColor, size: 36, targetScale: 1.8, duration: 1.5)
            
            // Main pin body
            ZStack {
                // Gradient circle base
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [tealLighter, tealColor],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
                
                // White border ring
                Circle()
                    .stroke(Color.white, lineWidth: 2.5)
                    .frame(width: 36, height: 36)
                
                // Map pin icon
                Image(systemName: "mappin")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .scaleEffect(hasDropped ? 1.0 : 0.3)
            .offset(y: hasDropped ? (isBouncing && !isSelected ? -3 : 0) : -50)
            .opacity(hasDropped ? 1.0 : 0)
            .animation(
                isSelected ? .easeOut(duration: 0.2) :
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                value: isBouncing
            )
        }
        .onAppear {
            // Drop animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                hasDropped = true
            }
            
            // Start bouncing after drop
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isBouncing = true
            }
        }
        .onChange(of: isSelected) { _, selected in
            // Stop bouncing when selected, resume when deselected
            if selected {
                isBouncing = false
            } else {
                withAnimation {
                    isBouncing = true
                }
            }
        }
    }
}

// MARK: - Pulse Ring Animation
struct PulseRing: View {
    let color: Color
    let size: CGFloat
    let targetScale: CGFloat
    let duration: Double
    var delay: Double = 0
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .stroke(color, lineWidth: 2)
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? targetScale : 1.0)
            .opacity(isAnimating ? 0 : 0.6)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.6) {
                    withAnimation(
                        .easeOut(duration: duration)
                        .repeatForever(autoreverses: false)
                    ) {
                        isAnimating = true
                    }
                }
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
