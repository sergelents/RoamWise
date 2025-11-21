//
//  OnboardingView.swift
//  Veou
//
//  Created on 4/10/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
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
            onboardingSteps[currentPage].backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Header with pagination
                HStack {
                    if currentPage > 0 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
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
                    
                    // Pagination dots
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingSteps.count, id: \.self) { index in
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
                TabView(selection: Binding(
                    get: { currentPage },
                    set: { newValue in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = newValue
                        }
                    }
                )) {
                    ForEach(0..<onboardingSteps.count, id: \.self) { index in
                        OnboardingStepView(step: onboardingSteps[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom button
                VStack(spacing: 12) {
                    Button {
                        if currentPage < onboardingSteps.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(currentPage == onboardingSteps.count - 1 ? "Get Started" : "Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            if currentPage < onboardingSteps.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
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
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
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

#Preview {
    OnboardingView()
}

