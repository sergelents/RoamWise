//
//  OnboardingView.swift
//  Veou
//
//  Created on 4/10/25.
//

import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @ObservedObject private var locationManager = LocationManager.shared
    
    // Preference selections
    @State private var selectedTravelStyles: Set<TravelStyle> = []
    @State private var selectedPreferences: Set<UserPreference> = []
    
    private let onboardingSteps: [OnboardingStep] = [
        OnboardingStep(
            icon: "map.fill",
            title: "Discover Safe Routes",
            description: "Explore community-powered safety ratings for streets, neighborhoods, and public spaces worldwide.",
            backgroundColor: LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.98, blue: 1.0),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            iconPosition: CGPoint(x: 50, y: -50)
        ),
        OnboardingStep(
            icon: "shield.fill",
            title: "Real-Time Safety Insights",
            description: "Get time-based reviews to know when places are safest and least crowded throughout the day.",
            backgroundColor: LinearGradient(
                colors: [
                    Color(red: 0.90, green: 0.96, blue: 0.98),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            iconPosition: CGPoint(x: 50, y: -40)
        ),
        OnboardingStep(
            icon: "trophy.fill",
            title: "Earn Rewards",
            description: "Share your experiences, help fellow travelers, and unlock badges as you explore the world.",
            backgroundColor: LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.97, blue: 0.95),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            iconPosition: CGPoint(x: 50, y: -40)
        )
    ]
    
    var body: some View {
        ZStack {
            // Dynamic background based on current page
            ZStack {
                if currentPage < onboardingSteps.count {
                    onboardingSteps[currentPage].backgroundColor
                } else if currentPage == onboardingSteps.count {
                    // Light purple gradient for location permission screen
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.92, blue: 0.98),
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    // White background for preference screens
                    Color.white
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with pagination
                HStack {
                    if currentPage > 0 {
                        Button {
                            currentPage -= 1
                        } label: {
                            Text("Back")
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .font(.system(size: 16, weight: .medium))
                        }
                    } else {
                        Spacer()
                            .frame(width: 60)
                    }
                    
                    Spacer()
                    
                    // Pagination dots (6 total: 3 steps + 1 location + 2 preference screens)
                    HStack(spacing: 8) {
                        ForEach(0..<(onboardingSteps.count + 3), id: \.self) { index in
                            if index == currentPage {
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: 24, height: 8)
                                    .cornerRadius(4)
                            } else {
                                Circle()
                                    .fill(Color(red: 0.8, green: 0.8, blue: 0.8))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Content area with TabView
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        // Onboarding steps (0-2)
                        ForEach(0..<onboardingSteps.count, id: \.self) { index in
                            OnboardingStepView(step: onboardingSteps[index])
                                .frame(width: geometry.size.width)
                        }
                        
                        // Location permission (3)
                        LocationPermissionView()
                            .frame(width: geometry.size.width)
                        
                        // Travel style preference (4)
                        TravelStyleView(selectedStyles: $selectedTravelStyles)
                            .frame(width: geometry.size.width)
                        
                        // User preferences (5)
                        PreferencesView(selectedPreferences: $selectedPreferences)
                            .frame(width: geometry.size.width)
                    }
                    .offset(x: -CGFloat(currentPage) * geometry.size.width)
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            let maxPage = onboardingSteps.count + 2 // 3 steps + location + 2 preferences
                            if value.translation.width > threshold && currentPage > 0 {
                                currentPage -= 1
                            } else if value.translation.width < -threshold && currentPage < maxPage {
                                currentPage += 1
                            }
                        }
                )
                
                // Bottom button section
                VStack(spacing: 12) {
                    if currentPage < onboardingSteps.count {
                        // Continue button for first 3 steps
                        Button {
                            let nextPage = currentPage + 1
                            // Use the binding setter which handles animation
                            currentPage = nextPage
                        } label: {
                            HStack(spacing: 8) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.4, blue: 0.9),
                                        Color(red: 0.1, green: 0.3, blue: 0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(
                                color: Color.blue.opacity(0.2),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        if currentPage == 0 {
                            Text("Swipe or tap to continue")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                        }
                    } else if currentPage == onboardingSteps.count {
                        // Location permission buttons (4th step)
                        Button {
                            locationManager.requestAuthorization()
                        } label: {
                            Text("Allow Location Access")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.4, blue: 0.9),
                                            Color(red: 0.1, green: 0.3, blue: 0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(
                                    color: Color.blue.opacity(0.2),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                        }
                        .padding(.horizontal, 20)
                        
                        Button {
                            // Move to preference screens instead of completing
                            currentPage = onboardingSteps.count + 1
                        } label: {
                            Text("Not Now")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        }
                    } else if currentPage == onboardingSteps.count + 1 {
                        // Travel style screen buttons
                        Button {
                            currentPage += 1
                        } label: {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.4, blue: 0.9),
                                            Color(red: 0.1, green: 0.3, blue: 0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(
                                    color: Color.blue.opacity(0.2),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                        }
                        .padding(.horizontal, 20)
                        
                        Button {
                            // Skip to next preference screen
                            currentPage += 1
                        } label: {
                            Text("Skip for now")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        }
                    } else {
                        // Preferences screen buttons (last screen)
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.4, blue: 0.9),
                                            Color(red: 0.1, green: 0.3, blue: 0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(
                                    color: Color.blue.opacity(0.2),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                        }
                        .padding(.horizontal, 20)
                        
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Skip for now")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        }
                    }
                }
                .padding(.bottom, 40)
        }
        .onChange(of: locationManager.authorizationStatus) { oldValue, newValue in
            // Move to preference screens when location permission is granted
            if newValue == .authorizedWhenInUse || newValue == .authorizedAlways {
                // Move to travel style screen after location is granted
                currentPage = onboardingSteps.count + 1
            }
        }
    }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    // Monitor location authorization status
    private func checkLocationPermission() {
        if locationManager.authorizationStatus == .authorizedWhenInUse || 
           locationManager.authorizationStatus == .authorizedAlways {
            completeOnboarding()
        }
    }
}

struct OnboardingStep {
    let icon: String
    let title: String
    let description: String
    let backgroundColor: LinearGradient
    let iconPosition: CGPoint
}

struct OnboardingStepView: View {
    let step: OnboardingStep
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Large circle with icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.98, green: 0.98, blue: 0.98))
                    .frame(width: 280, height: 280)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 25,
                        x: 0,
                        y: 12
                    )
                
                // Icon positioned based on step
                Image(systemName: step.icon)
                    .font(.system(size: 70, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.blue,
                                Color.blue.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(x: step.iconPosition.x, y: step.iconPosition.y)
            }
            .padding(.bottom, 50)
            
            // Title
            Text(step.title)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.25))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 16)
            
            // Description
            Text(step.description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Location Permission View
struct LocationPermissionView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Large circle with location pin icon
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 280, height: 280)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 25,
                        x: 0,
                        y: 12
                    )
                
                // Location pin icon
                Image(systemName: "mappin")
                    .font(.system(size: 70, weight: .medium))
                    .foregroundColor(.red)
                    .offset(x: 50, y: -40)
            }
            .padding(.bottom, 50)
            
            // Title
            Text("Enable Location Services")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.25))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 16)
            
            // Description
            Text("To provide you with relevant safety information and nearby reviews, we'd like to access your location. You can change this anytime in your device settings.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Privacy text
            Text("We respect your privacy. Location data is only used to show nearby safety information.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Travel Style View
enum TravelStyle: String, CaseIterable {
    case solo = "Solo traveler"
    case family = "With family"
    case friends = "With friends"
    case digitalNomad = "Digital nomad"
    case businessTraveler = "Business traveler"
}

struct TravelStyleView: View {
    @Binding var selectedStyles: Set<TravelStyle>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Icon at top
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.4, blue: 0.9),
                                    Color(red: 0.3, green: 0.5, blue: 0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.yellow)
                }
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Title
                Text("Help Us Personalize RoamWise")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 12)
                
                // Subtitle
                Text("Tell us about your travel style so we can show you the most relevant insights")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                
                // Question
                Text("I usually travel as:")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                
                Text("(select all that apply)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                
                // Options
                VStack(spacing: 12) {
                    ForEach(TravelStyle.allCases, id: \.self) { style in
                        TravelStyleOption(
                            style: style,
                            isSelected: selectedStyles.contains(style),
                            onTap: {
                                if selectedStyles.contains(style) {
                                    selectedStyles.remove(style)
                                } else {
                                    selectedStyles.insert(style)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
        }
    }
}

struct TravelStyleOption: View {
    let style: TravelStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    var iconName: String {
        switch style {
        case .solo: return "person.fill" // Solo traveler with backpack
        case .family: return "figure.2.and.child.holdinghands"
        case .friends: return "person.2.fill" // Two people
        case .digitalNomad: return "laptopcomputer"
        case .businessTraveler: return "briefcase.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                }
                
                Text(style.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Spacer()
                
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.4, blue: 0.9))
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Preferences View
enum UserPreference: String, CaseIterable {
    case safety = "Safety"
    case avoidingCrowds = "Avoiding crowds"
    case hiddenGems = "Finding hidden gems"
    case budgetFriendly = "Budget-friendly spots"
    case familyFriendly = "Family-friendly locations"
}

struct PreferencesView: View {
    @Binding var selectedPreferences: Set<UserPreference>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)
                
                // Title
                Text("I care most about:")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                
                // Options
                VStack(spacing: 12) {
                    ForEach(UserPreference.allCases, id: \.self) { preference in
                        PreferenceOption(
                            preference: preference,
                            isSelected: selectedPreferences.contains(preference),
                            onTap: {
                                if selectedPreferences.contains(preference) {
                                    selectedPreferences.remove(preference)
                                } else {
                                    selectedPreferences.insert(preference)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
        }
    }
}

struct PreferenceOption: View {
    let preference: UserPreference
    let isSelected: Bool
    let onTap: () -> Void
    
    var iconName: String {
        switch preference {
        case .safety: return "shield.fill"
        case .avoidingCrowds: return "figure.walk" // Person with backpack
        case .hiddenGems: return "sparkles"
        case .budgetFriendly: return "dollarsign.circle.fill"
        case .familyFriendly: return "face.smiling"
        }
    }
    
    var iconColor: Color {
        switch preference {
        case .safety: return .red
        case .avoidingCrowds: return Color(red: 0.3, green: 0.4, blue: 0.7) // Dark blue/purple
        case .hiddenGems: return .blue
        case .budgetFriendly: return .orange // Gold/yellow
        case .familyFriendly: return .yellow
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                Text(preference.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Spacer()
                
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.4, blue: 0.9))
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    OnboardingView()
}

