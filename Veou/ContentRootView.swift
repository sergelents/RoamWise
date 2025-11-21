//
//  ContentRootView.swift
//  Veou
//
//  Created on 4/10/25.
//

import SwiftUI

struct ContentRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if !isAuthenticated {
                AuthView()
                    .transition(.opacity)
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.5), value: isAuthenticated)
    }
}

#Preview {
    ContentRootView()
}

