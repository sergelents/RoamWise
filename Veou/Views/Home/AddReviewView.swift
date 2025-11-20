//
//  AddReviewView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI

struct AddReviewView: View {
    let place: PlaceAnnotation
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTimeOfDay: TimeOfDay?
    @State private var safetyRating: Int = 0
    @State private var crowdRating: Int = 0
    @State private var reviewText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    enum TimeOfDay: String, CaseIterable {
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
    
    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Location Header
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(place.title)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(place.subtitle.isEmpty ? "Location" : place.subtitle)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // When did you visit?
                    VStack(alignment: .leading, spacing: 16) {
                        Text("When did you visit?")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(TimeOfDay.allCases, id: \.self) { time in
                                TimeOfDayButton(
                                    timeOfDay: time,
                                    isSelected: selectedTimeOfDay == time,
                                    action: { selectedTimeOfDay = time }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // How safe did you feel?
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How safe did you feel?")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { index in
                                Button(action: {
                                    safetyRating = index
                                }) {
                                    Image(systemName: index <= safetyRating ? "star.fill" : "star")
                                        .font(.system(size: 32))
                                        .foregroundColor(index <= safetyRating ? .orange : Color(.systemGray4))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    
                    // How crowded was it?
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How crowded was it?")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { index in
                                Button(action: {
                                    crowdRating = index
                                }) {
                                    Image(systemName: index <= crowdRating ? "star.fill" : "star")
                                        .font(.system(size: 32))
                                        .foregroundColor(index <= crowdRating ? .orange : Color(.systemGray4))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    
                    // Share your experience
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Share your experience")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $reviewText)
                                .font(.system(size: 15))
                                .frame(minHeight: 120)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .focused($isTextFieldFocused)
                            
                            if reviewText.isEmpty {
                                Text("Tell other travelers about your visit...")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(.systemGray3))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        Text("\(reviewText.count) characters")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    
                    // Add photos
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add photos (optional)")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            // Photo picker action
                        }) {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                .foregroundColor(Color(.systemGray4))
                                .frame(height: 100)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 32))
                                            .foregroundColor(.gray)
                                        Text("Add Photos")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Post Review Button
                    Button(action: {
                        // Post review action
                        dismiss()
                    }) {
                        Text("Post Review")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                isFormValid ? Color(red: 1.0, green: 0.42, blue: 0.42) : Color(.systemGray5)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Add Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Post") {
                    // Post action
                    dismiss()
                }
                .foregroundColor(isFormValid ? .blue : .gray)
                .disabled(!isFormValid)
            }
        }
        .background(Color(.systemBackground))
    }
    
    private var isFormValid: Bool {
        selectedTimeOfDay != nil && 
        safetyRating > 0 && 
        crowdRating > 0 && 
        !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Time of Day Button
struct TimeOfDayButton: View {
    let timeOfDay: AddReviewView.TimeOfDay
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: timeOfDay.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(timeOfDay.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.blue.opacity(0.05) : Color(.systemBackground))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        AddReviewView(
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

