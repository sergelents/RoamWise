//
//  ReviewTooltipView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI

struct ReviewTooltipView: View {
    var body: some View {
        Text("Pick location and tap to write review")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(red: 1.0, green: 0.42, blue: 0.42))
            .cornerRadius(20)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
        VStack {
            Spacer()
            HStack {
                Spacer()
                ReviewTooltipView()
                    .padding(.trailing, 24)
                    .padding(.bottom, 180)
            }
        }
    }
}

