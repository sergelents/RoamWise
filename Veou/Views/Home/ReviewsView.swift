//
//  ReviewsView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI

struct ReviewsView: View {
    let place: PlaceAnnotation
    @State private var selectedTimeFilter: TimeFilter = .all
    @StateObject private var summaryViewModel = ReviewSummaryViewModel()
    
    enum TimeFilter: String, CaseIterable {
        case all = "All"
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case night = "Night"
        
        var icon: String? {
            switch self {
            case .all: return nil
            case .morning: return "sunrise.fill"
            case .afternoon: return "sun.max.fill"
            case .evening: return "sunset.fill"
            case .night: return "moon.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Location Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text(place.subtitle.isEmpty ? "Location" : place.subtitle)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    
                    if let distance = place.distance {
                        Text(String(format: "%.1f mi away", distance))
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Info cards
                HStack(spacing: 12) {
                    // Safety rating card
                    ReviewInfoCard {
                        VStack(spacing: 8) {
                            Text(String(format: "%.1f", place.rating))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            + Text(" /5")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                            
                            // Star rating
                            HStack(spacing: 2) {
                                ForEach(0..<5) { index in
                                    Image(systemName: starIcon(for: index, rating: place.rating))
                                        .font(.system(size: 12))
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Text("Safety")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Crowd level card
                    ReviewInfoCard {
                        VStack(spacing: 8) {
                            Text(String(format: "%.1f", crowdRating))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            + Text(" /5")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                            
                            Image(systemName: place.crowdLevel.icon)
                                .font(.system(size: 18))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("Crowd")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Reviews card
                    ReviewInfoCard {
                        VStack(spacing: 8) {
                            Text("\(place.reviewCount)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("Reviews")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // AI Summary Section
                AISummarySection(
                    viewModel: summaryViewModel,
                    reviews: filteredReviews,
                    locationName: place.title,
                    reviewCount: filteredReviews.count
                )
                .padding(.horizontal, 20)
                
                // Filter by time
                VStack(alignment: .leading, spacing: 12) {
                    Text("Filter by time")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TimeFilter.allCases, id: \.self) { filter in
                                TimeFilterButton(
                                    filter: filter,
                                    isSelected: selectedTimeFilter == filter,
                                    action: { selectedTimeFilter = filter }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Reviews section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Reviews (\(mockReviews.count))")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    ForEach(filteredReviews) { review in
                        ReviewCard(review: review)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(place.title)
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemBackground))
        .onAppear {
            Task {
                await summaryViewModel.generateSummary(
                    reviews: filteredReviews,
                    locationName: place.title
                )
            }
        }
        .onChange(of: selectedTimeFilter) { _ in
            Task {
                await summaryViewModel.generateSummary(
                    reviews: filteredReviews,
                    locationName: place.title
                )
            }
        }
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
    
    private var crowdRating: Double {
        // Convert crowd level to numeric rating
        switch place.crowdLevel {
        case .low: return 1.5
        case .medium: return 3.2
        case .high: return 4.5
        }
    }
    
    private var filteredReviews: [Review] {
        if selectedTimeFilter == .all {
            return mockReviews
        }
        return mockReviews.filter { $0.timeOfDay.rawValue.lowercased() == selectedTimeFilter.rawValue.lowercased() }
    }
    
    private var mockReviews: [Review] {
        [
            Review(
                id: "1",
                username: "SafeTraveler",
                userLevel: 5,
                timeOfDay: .morning,
                timestamp: "22mo ago",
                safetyRating: 5,
                crowdRating: 2,
                text: "Perfect for a morning jog! Very peaceful with just a few other runners and dog walkers. Felt completely safe the entire time.",
                helpfulCount: 24
            ),
            Review(
                id: "2",
                username: "NomadLife",
                userLevel: 12,
                timeOfDay: .afternoon,
                timestamp: "22mo ago",
                safetyRating: 4,
                crowdRating: 4,
                text: "Gets pretty busy in the afternoon, especially on weekends. Still feels safe but can be crowded near popular spots like Bethesda Fountain.",
                helpfulCount: 18
            ),
            Review(
                id: "3",
                username: "CityWanderer",
                userLevel: 8,
                timeOfDay: .evening,
                timestamp: "22mo ago",
                safetyRating: 4,
                crowdRating: 3,
                text: "Beautiful during sunset! Crowds thin out a bit. Stick to well-lit paths and you'll be fine. Great for an evening stroll.",
                helpfulCount: 31
            ),
            Review(
                id: "4",
                username: "TravelExplorer",
                userLevel: 3,
                timeOfDay: .night,
                timestamp: "22mo ago",
                safetyRating: 3,
                crowdRating: 1,
                text: "Quite empty at night. Some areas are poorly lit. I'd recommend staying near the main paths and going with a friend if possible.",
                helpfulCount: 42
            ),
            Review(
                id: "5",
                username: "NomadLife",
                userLevel: 12,
                timeOfDay: .morning,
                timestamp: "22mo ago",
                safetyRating: 5,
                crowdRating: 2,
                text: "Love the morning atmosphere here! Very safe, lots of families and joggers. The air is fresh and it's not too crowded.",
                helpfulCount: 15
            )
        ]
    }
}

// MARK: - Review Model
struct Review: Identifiable {
    let id: String
    let username: String
    let userLevel: Int
    let timeOfDay: TimeOfDay
    let timestamp: String
    let safetyRating: Int
    let crowdRating: Int
    let text: String
    let helpfulCount: Int
    
    enum TimeOfDay: String {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case night = "Night"
        
        var icon: String {
            switch self {
            case .morning: return "sunrise.fill"
            case .afternoon: return "sun.max.fill"
            case .evening: return "sunset.fill"
            case .night: return "moon.fill"
            }
        }
    }
}

// MARK: - Review Info Card
struct ReviewInfoCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

// MARK: - Time Filter Button
struct TimeFilterButton: View {
    let filter: ReviewsView.TimeFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = filter.icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(filter.rawValue)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(20)
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User header
            HStack(spacing: 12) {
                // Profile picture placeholder
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(review.username.prefix(1)))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(review.username)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // Level badge
                        Text("Lv \(review.userLevel)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: review.timeOfDay.icon)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text(review.timeOfDay.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text(review.timestamp)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            
            // Ratings
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("Safety:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < review.safetyRating ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(index < review.safetyRating ? .orange : Color(.systemGray4))
                        }
                    }
                }
                
                HStack(spacing: 4) {
                    Text("Crowd:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < review.crowdRating ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(index < review.crowdRating ? .orange : Color(.systemGray4))
                        }
                    }
                }
            }
            
            // Review text
            Text(review.text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            // Helpful button
            Button(action: {
                // Mark as helpful action
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "hand.thumbsup")
                        .font(.system(size: 14))
                    Text("Helpful (\(review.helpfulCount))")
                        .font(.system(size: 14))
                }
                .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - AI Summary Section
struct AISummarySection: View {
    @ObservedObject var viewModel: ReviewSummaryViewModel
    let reviews: [Review]
    let locationName: String
    let reviewCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                viewModel.toggleExpanded()
            }) {
                HStack {
                    HStack(spacing: 8) {
                        Text("AI Summary")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // Beta badge
                        Text("Beta")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Image(systemName: viewModel.isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 16)
            }
            
            if viewModel.isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Review count text
                    Text("Based on \(reviewCount) community reviews")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    // Loading state
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating summary...")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 20)
                    }
                    // Error state
                    else if let errorMessage = viewModel.errorMessage {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Unable to generate summary")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                Task {
                                    await viewModel.retrySummary(
                                        reviews: reviews,
                                        locationName: locationName
                                    )
                                }
                            }) {
                                Text("Retry")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    // Summary content
                    else if let summary = viewModel.summary {
                        VStack(alignment: .leading, spacing: 20) {
                            // Overall Safety Consensus
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Overall Safety Consensus:")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(summary.overallSafetyConsensus)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                    .lineSpacing(4)
                            }
                            
                            // Key Warnings
                            if !summary.keyWarnings.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "exclamation.triangle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.red)
                                        
                                        Text("Key Concerns:")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(summary.keyWarnings, id: \.self) { warning in
                                            HStack(alignment: .top, spacing: 8) {
                                                Text("•")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.red)
                                                
                                                Text(warning)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.primary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Best Times to Visit
                            if !summary.bestTimesToVisit.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.orange)
                                        
                                        Text("Best Time to Visit:")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(summary.bestTimesToVisit, id: \.self) { time in
                                            HStack(alignment: .top, spacing: 8) {
                                                Text("•")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.orange)
                                                
                                                Text(time)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.primary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // Disclaimer
                        Text("AI-generated summary • Always use your best judgment.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        ReviewsView(
            place: PlaceAnnotation(
                coordinate: .init(latitude: 40.785091, longitude: -73.968285),
                title: "Central Park",
                subtitle: "59th to 110th St, New York, NY",
                rating: 4.5,
                reviewCount: 234,
                crowdLevel: .medium,
                distance: 0.5
            )
        )
    }
}

