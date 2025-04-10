import SwiftUI
import MapKit

struct LocationResult: Identifiable {
    let id: String
    let name: String
    let address: String
    let coordinates: CLLocationCoordinate2D?
    let isPopular: Bool
    
    init(id: String, name: String, address: String, coordinates: CLLocationCoordinate2D?, isPopular: Bool = false) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinates = coordinates
        self.isPopular = isPopular
    }
}

struct SearchResultsView: View {
    let results: [LocationResult]
    let onSelectLocation: (LocationResult) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                if !popularLocations.isEmpty {
                    Section {
                        ForEach(popularLocations) { location in
                            LocationRowView(location: location)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onSelectLocation(location)
                                }
                            
                            if location.id != popularLocations.last?.id {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    } header: {
                        Text("Popular Nearby")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(.ultraThinMaterial)
                    }
                }
                
                if !otherLocations.isEmpty {
                    Section {
                        ForEach(otherLocations) { location in
                            LocationRowView(location: location)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onSelectLocation(location)
                                }
                            
                            if location.id != otherLocations.last?.id {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    } header: {
                        if !popularLocations.isEmpty {
                            Text("Other Locations")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(.ultraThinMaterial)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: min(CGFloat(results.count) * 70, 350))
        .background(Color(.systemBackground).opacity(0.98))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
    
    // Separate popular locations from others
    private var popularLocations: [LocationResult] {
        results.filter { $0.isPopular }
    }
    
    private var otherLocations: [LocationResult] {
        results.filter { !$0.isPopular }
    }
}

struct LocationRowView: View {
    let location: LocationResult
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(location.isPopular ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .frame(width: 40, height: 40)
                
                Image(systemName: location.isPopular ? "star.fill" : "mappin.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(location.isPopular ? .blue : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                
                Text(location.address)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .padding(.trailing, 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.clear)
                .contentShape(Rectangle())
        )
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        
        SearchResultsView(
            results: [
                LocationResult(id: "1", name: "Town Square", address: "Main Street, 123", coordinates: nil, isPopular: true),
                LocationResult(id: "2", name: "Town Square", address: "Center District, 456", coordinates: nil, isPopular: true),
                LocationResult(id: "3", name: "Town Square", address: "Downtown Area, 789", coordinates: nil),
                LocationResult(id: "4", name: "City Hall", address: "Government District, 101", coordinates: nil)
            ],
            onSelectLocation: { _ in }
        )
        .padding()
    }
} 