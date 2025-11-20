//
//  ReviewTooltipView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI

struct ReviewTooltipView: View {
    var onDismiss: (() -> Void)?
    
    var body: some View {
        // Tooltip modal with speech bubble tail
        ZStack {
            VStack(alignment: .center, spacing: 12) {
                // Spacer for X button space at top
                Spacer()
                    .frame(height: 20)
                
                Text("Pick your location and tap to write a review")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                    
                    Text("Tap anywhere to continue")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(20)
            .background(
                ZStack {
                    // Main rounded rectangle
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.1, green: 0.2, blue: 0.4))
                    
                    // Speech bubble tail pointing up
                    SpeechBubbleTail()
                        .fill(Color(red: 0.1, green: 0.2, blue: 0.4))
                        .frame(width: 20, height: 12)
                        .offset(y: -6)
                }
            )
            .frame(maxWidth: 320)
            .padding(.horizontal, 20)
            .overlay(alignment: .topTrailing) {
                Button {
                    onDismiss?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                }
                .padding(20)
            }
        }
    }
}

struct SpeechBubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create upward-pointing triangle
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
        VStack {
            Spacer()
            ReviewTooltipView()
        }
    }
}

