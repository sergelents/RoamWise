//
//  SocialLoginButton.swift
//  Veou
//
//  Created on 4/10/25.
//

import SwiftUI

enum SocialProvider {
    case apple
    case google
    
    var title: String {
        switch self {
        case .apple:
            return "Login with Apple"
        case .google:
            return "Login with Google"
        }
    }
    
    var icon: String {
        switch self {
        case .apple:
            return "apple.logo"
        case .google:
            return "globe"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .apple:
            return .black
        case .google:
            return .blue
        }
    }
}

struct SocialLoginButton: View {
    let provider: SocialProvider
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if provider == .google {
                    // Google logo representation - using colored G
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                        
                        Text("G")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.26, green: 0.52, blue: 0.96),
                                        Color(red: 0.52, green: 0.76, blue: 0.26),
                                        Color(red: 1.0, green: 0.84, blue: 0.0),
                                        Color(red: 1.0, green: 0.34, blue: 0.13)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                } else {
                    Image(systemName: provider.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(provider.iconColor)
                }
                
                Text(provider.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SocialLoginButton(provider: .apple) {
            print("Apple login tapped")
        }
        
        SocialLoginButton(provider: .google) {
            print("Google login tapped")
        }
    }
    .padding()
    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
}

