//
//  ReviewSummaryViewModel.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import Foundation
import SwiftUI

// MARK: - Review Summary ViewModel
@MainActor
class ReviewSummaryViewModel: ObservableObject {
    @Published var summary: AISummary?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isExpanded: Bool = false
    
    private var generateTask: Task<Void, Never>?
    private var lastReviewHash: Int?
    private var isInitialLoad: Bool = true
    private let debounceDelay: TimeInterval = 0.2 // 200ms debounce for filter changes only
    
    private let anthropicService = AnthropicService.shared
    
    func toggleExpanded() {
        isExpanded.toggle()
    }
    
    func generateSummary(reviews: [Review], locationName: String) async {
        // Cancel any existing task
        generateTask?.cancel()
        
        // Calculate hash of current reviews to detect changes
        let reviewHash = reviews.computeHash()
        
        // If reviews haven't changed and we already have a summary, skip
        if reviewHash == lastReviewHash, summary != nil {
            return
        }
        
        // If no reviews, clear summary
        guard !reviews.isEmpty else {
            summary = nil
            errorMessage = nil
            lastReviewHash = reviewHash
            isInitialLoad = false
            return
        }
        
        // Determine if this is initial load or filter change
        let shouldDebounce = !isInitialLoad && summary != nil
        
        // For initial load, generate immediately. For filter changes, debounce.
        generateTask = Task { @MainActor in
            // Only debounce if we have an existing summary (filter change scenario)
            if shouldDebounce {
                try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            }
            
            guard !Task.isCancelled else { return }
            
            await performSummaryGeneration(reviews: reviews, locationName: locationName, reviewHash: reviewHash)
            isInitialLoad = false
        }
    }
    
    private func performSummaryGeneration(reviews: [Review], locationName: String, reviewHash: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let generatedSummary = try await anthropicService.generateReviewSummary(
                reviews: reviews,
                locationName: locationName
            )
            
            // Only update if task wasn't cancelled
            guard !Task.isCancelled else { return }
            
            summary = generatedSummary
            lastReviewHash = reviewHash
            errorMessage = nil
        } catch {
            // Only update if task wasn't cancelled
            guard !Task.isCancelled else { return }
            
            errorMessage = error.localizedDescription
            summary = nil
        }
        
        isLoading = false
    }
    
    func retrySummary(reviews: [Review], locationName: String) async {
        lastReviewHash = nil // Force regeneration
        await generateSummary(reviews: reviews, locationName: locationName)
    }
    
    func clearSummary() {
        generateTask?.cancel()
        summary = nil
        errorMessage = nil
        isLoading = false
        lastReviewHash = nil
        isInitialLoad = true
    }
}

// MARK: - Array Hash Extension for Review Comparison
extension Array where Element == Review {
    func computeHash() -> Int {
        var hasher = Hasher()
        for review in self {
            hasher.combine(review.id)
            hasher.combine(review.safetyRating)
            hasher.combine(review.crowdRating)
            hasher.combine(review.timeOfDay.rawValue)
            hasher.combine(review.text)
        }
        return hasher.finalize()
    }
}

