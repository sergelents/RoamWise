//
//  LocationDetailView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI

struct LocationDetailView: View {
    let place: PlaceAnnotation
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                // Location name
                Text(place.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                // Address
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(place.subtitle.isEmpty ? "Location" : place.subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // Distance
                if let distance = place.distance {
                    Text(String(format: "%.1f mi away", distance))
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // Info cards
                HStack(spacing: 12) {
                    // Safety rating card
                    InfoCard {
                        VStack(spacing: 8) {
                            Text(String(format: "%.1f", place.rating))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                            + Text(" /5")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                            
                            // Star rating
                            HStack(spacing: 2) {
                                ForEach(0..<5) { index in
                                    Image(systemName: starIcon(for: index, rating: place.rating))
                                        .font(.system(size: 14))
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Text("Safety")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Crowd level card
                    InfoCard {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(crowdColor.opacity(0.15))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(crowdColor)
                            }
                            
                            Text("Crowd")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Reviews card
                    InfoCard {
                        VStack(spacing: 8) {
                            Text("\(place.reviewCount)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("Reviews")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 8)
                
                // View All Reviews button
                Button(action: {
                    // Action for viewing all reviews
                }) {
                    HStack {
                        Spacer()
                        Text("View All Reviews")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 18)
                    .background(Color(red: 0.25, green: 0.32, blue: 0.58))
                    .cornerRadius(12)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
    }
    
    private func starIcon(for index: Int, rating: Double) -> String {
        let position = Double(index) + 1.0
        if rating >= position {
            return "star.fill"
        } else if rating >= position - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
    
    private var crowdColor: Color {
        switch place.crowdLevel {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

// MARK: - Info Card Component
struct InfoCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

#Preview {
    LocationDetailView(
        place: PlaceAnnotation(
            coordinate: .init(latitude: 40.785091, longitude: -73.968285),
            title: "Central Park",
            subtitle: "59th to 110th St, New York, NY",
            rating: 4.5,
            reviewCount: 234,
            crowdLevel: .medium,
            distance: 0.5
        ),
        isPresented: .constant(true)
    )
    .presentationDetents([.height(420)])
}
