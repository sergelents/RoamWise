//
//  AnthropicService.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import Foundation

// MARK: - Anthropic Service
class AnthropicService {
    static let shared = AnthropicService()
    
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    
    private init() {
        // Get API key from environment variable or Info.plist
        // For now, using environment variable. User should set ANTHROPIC_API_KEY
        if let key = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] {
            self.apiKey = key
        } else {
            // Fallback: try to get from Info.plist (user needs to add it)
            self.apiKey = Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_API_KEY") as? String ?? ""
        }
    }
    
    func generateReviewSummary(reviews: [Review], locationName: String) async throws -> AISummary {
        guard !apiKey.isEmpty else {
            throw AnthropicError.missingAPIKey
        }
        
        guard !reviews.isEmpty else {
            throw AnthropicError.noReviews
        }
        
        let prompt = buildPrompt(reviews: reviews, locationName: locationName)
        
        let enhancedPrompt = prompt + """
        
        Please respond with ONLY a valid JSON object in this exact format (no markdown, no code blocks, just the JSON):
        {
            "overallSafetyConsensus": "2-3 sentence summary here",
            "keyWarnings": ["warning 1", "warning 2"],
            "bestTimesToVisit": ["time recommendation 1", "time recommendation 2"]
        }
        """
        
        let requestBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 1024,
            "messages": [
                [
                    "role": "user",
                    "content": enhancedPrompt
                ]
            ]
        ]
        
        guard let url = URL(string: baseURL) else {
            throw AnthropicError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw AnthropicError.invalidRequest
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AnthropicError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorData["error"] as? [String: Any],
                   let message = errorMessage["message"] as? String {
                    throw AnthropicError.apiError(message)
                }
                throw AnthropicError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(AnthropicResponse.self, from: data)
            
            // Extract JSON from the content
            guard let content = apiResponse.content.first,
                  content.type == "text" else {
                throw AnthropicError.invalidResponse
            }
            
            let jsonString = content.text
            
            // Parse the JSON string to AISummary
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw AnthropicError.invalidResponse
            }
            
            let summary = try decoder.decode(AISummary.self, from: jsonData)
            return summary
            
        } catch let error as AnthropicError {
            throw error
        } catch {
            throw AnthropicError.decodingError(error.localizedDescription)
        }
    }
    
    private func buildPrompt(reviews: [Review], locationName: String) -> String {
        var prompt = """
        Analyze the following reviews for \(locationName) and provide a comprehensive safety summary.
        
        Reviews:
        """
        
        for (index, review) in reviews.enumerated() {
            prompt += """
            
            Review \(index + 1):
            - Time of Day: \(review.timeOfDay.rawValue)
            - Safety Rating: \(review.safetyRating)/5
            - Crowd Rating: \(review.crowdRating)/5
            - Review Text: \(review.text)
            """
        }
        
        prompt += """
        
        Please analyze these reviews and provide:
        1. Overall Safety Consensus: A 2-3 sentence summary of the general safety perception based on all reviews
        2. Key Warnings: List specific safety concerns, warnings, or issues mentioned in the reviews
        3. Best Times to Visit: Identify the best times to visit based on safety ratings, crowd levels, and review patterns
        
        Focus on safety-related information and practical advice for travelers.
        """
        
        return prompt
    }
}

// MARK: - Anthropic Response Models
private struct AnthropicResponse: Codable {
    let content: [ContentBlock]
}

private struct ContentBlock: Codable {
    let type: String
    let text: String
}

// MARK: - Anthropic Errors
enum AnthropicError: LocalizedError {
    case missingAPIKey
    case noReviews
    case invalidURL
    case invalidRequest
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Anthropic API key is missing. Please set ANTHROPIC_API_KEY environment variable or add it to Info.plist"
        case .noReviews:
            return "No reviews available to generate summary"
        case .invalidURL:
            return "Invalid API URL"
        case .invalidRequest:
            return "Failed to create API request"
        case .invalidResponse:
            return "Invalid response from API"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        }
    }
}

