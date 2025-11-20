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
        VStack(alignment: .center, spacing: 12) {
            Text("First pick your location, then tap + to write a review")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                
                Text("Tap anywhere to continue")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Main rounded rectangle - matching floating action button color
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.42))
                
                // Speech bubble tail pointing up
                SpeechBubbleTail()
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.42))
                    .frame(width: 20, height: 12)
                    .offset(y: -6)
            }
        )
        .frame(maxWidth: 320)
        .padding(.horizontal, 20)
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

