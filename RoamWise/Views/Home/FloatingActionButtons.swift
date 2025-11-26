//
//  FloatingActionButtons.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI
import UIKit

struct FloatingActionButtons: View {
    let annotations: [PlaceAnnotation]
    let selectedPlace: PlaceAnnotation?
    let onLocationTap: () -> Void
    let onAddReviewTap: (PlaceAnnotation) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Location button (white circular FAB)
            Button(action: onLocationTap) {
                Image(systemName: "location")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 56, height: 56)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            // Add Review button (coral FAB)
            Button(action: {
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                let placeToReview = selectedPlace ?? annotations.last
                if let place = placeToReview {
                    onAddReviewTap(place)
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(red: 1.0, green: 0.42, blue: 0.42))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .opacity(!annotations.isEmpty ? 1.0 : 0.5)
            .disabled(annotations.isEmpty)
        }
    }
}

#Preview {
    FloatingActionButtons(
        annotations: [],
        selectedPlace: nil,
        onLocationTap: {},
        onAddReviewTap: { _ in }
    )
}

