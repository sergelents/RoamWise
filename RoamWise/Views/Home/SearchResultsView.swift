//
//  SearchResultsView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct SearchResultsView: View {
    let suggestions: [SearchSuggestion]
    let onSelect: (SearchSuggestion) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(suggestions) { suggestion in
                    SearchSuggestionRow(suggestion: suggestion)
                        .contentShape(Rectangle())
                        .onTapGesture { onSelect(suggestion) }
                    
                    if suggestion.id != suggestions.last?.id {
                        Divider().padding(.leading, 56)
                    }
                }
            }
        }
        .frame(maxHeight: min(CGFloat(suggestions.count) * 60, 300))
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct SearchSuggestionRow: View {
    let suggestion: SearchSuggestion
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(suggestion.isPopular ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: suggestion.isPopular ? "star.fill" : "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(suggestion.isPopular ? .blue : .gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(suggestion.title)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let distance = suggestion.distance {
                        Text(formatDistance(distance))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Text(suggestion.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Image(systemName: "arrow.up.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

#Preview {
    SearchResultsView(
        suggestions: [
            SearchSuggestion(
                id: "1",
                title: "Starbucks Coffee",
                subtitle: "123 Main St, San Francisco",
                coordinates: nil,
                isPopular: true,
                distance: 250
            ),
            SearchSuggestion(
                id: "2",
                title: "Golden Gate Park",
                subtitle: "San Francisco, CA",
                coordinates: nil,
                isPopular: true,
                distance: 1200
            )
        ],
        onSelect: { _ in }
    )
    .padding()
} 