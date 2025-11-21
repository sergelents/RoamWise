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
                } else {
                    // Light purple gradient for location permission screen
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.92, blue: 0.98),
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
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
                    
                    // Pagination dots (4 total: 3 regular steps + 1 location permission)
                    HStack(spacing: 8) {
                        ForEach(0..<(onboardingSteps.count + 1), id: \.self) { index in
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
                        ForEach(0..<(onboardingSteps.count + 1), id: \.self) { index in
                            Group {
                                if index < onboardingSteps.count {
                                    OnboardingStepView(step: onboardingSteps[index])
                                } else {
                                    LocationPermissionView()
                                }
                            }
                            .frame(width: geometry.size.width)
                        }
                    }
                    .offset(x: -CGFloat(currentPage) * geometry.size.width)
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width > threshold && currentPage > 0 {
                                currentPage -= 1
                            } else if value.translation.width < -threshold && currentPage < onboardingSteps.count {
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
                    } else {
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
                            completeOnboarding()
                        } label: {
                            Text("Not Now")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        }
                    }
                }
                .padding(.bottom, 40)
        }
        .onChange(of: locationManager.authorizationStatus) { oldValue, newValue in
            // Complete onboarding when location permission is granted
            if newValue == .authorizedWhenInUse || newValue == .authorizedAlways {
                completeOnboarding()
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

#Preview {
    OnboardingView()
}

