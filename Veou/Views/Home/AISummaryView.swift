//
//  AISummaryView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI

// MARK: - AI Summary Section
struct AISummarySection: View {
    @ObservedObject var viewModel: ReviewSummaryViewModel
    let reviews: [Review]
    let locationName: String
    let reviewCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                viewModel.toggleExpanded()
            }) {
                HStack {
                    HStack(spacing: 8) {
                        Text("AI Summary")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // Beta badge
                        Text("Beta")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Image(systemName: viewModel.isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 16)
            }
            
            if viewModel.isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Review count text
                    Text("Based on \(reviewCount) community reviews")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    // Loading state
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating summary...")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 20)
                    }
                    // Error state
                    else if let errorMessage = viewModel.errorMessage {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Unable to generate summary")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                Task {
                                    await viewModel.retrySummary(
                                        reviews: reviews,
                                        locationName: locationName
                                    )
                                }
                            }) {
                                Text("Retry")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    // Summary content
                    else if let summary = viewModel.summary {
                        VStack(alignment: .leading, spacing: 20) {
                            // Overall Safety Consensus
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Overall Safety Consensus:")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(summary.overallSafetyConsensus)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                    .lineSpacing(4)
                            }
                            
                            // Key Warnings
                            if !summary.keyWarnings.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "exclamation.triangle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.red)
                                        
                                        Text("Key Concerns:")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(summary.keyWarnings, id: \.self) { warning in
                                            HStack(alignment: .top, spacing: 8) {
                                                Text("•")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.red)
                                                
                                                Text(warning)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.primary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Best Times to Visit
                            if !summary.bestTimesToVisit.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.orange)
                                        
                                        Text("Best Time to Visit:")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(summary.bestTimesToVisit, id: \.self) { time in
                                            HStack(alignment: .top, spacing: 8) {
                                                Text("•")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.orange)
                                                
                                                Text(time)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.primary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // Disclaimer
                        Text("AI-generated summary • Always use your best judgment.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

