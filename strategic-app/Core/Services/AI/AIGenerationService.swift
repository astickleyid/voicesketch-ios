//
//  AIGenerationService.swift
//  VoiceSketch
//

import Foundation

/// Protocol for AI image generation services
protocol AIGenerationService: Actor {
    /// Generate image from request
    func generate(_ request: GenerationRequest) async throws -> Data
    
    /// Check if service is available
    func isAvailable() async -> Bool
    
    /// Get estimated cost per generation
    func estimatedCost(for quality: ImageQuality) -> Decimal
}

/// AI service provider types
enum AIProvider: String, Codable, Sendable {
    case falAI = "fal.ai"
    case dalle = "DALL-E"
    case stable = "Stable Diffusion"
    
    var displayName: String { rawValue }
}

/// Factory for creating AI services
actor AIServiceFactory {
    private let logger = AppLogger(category: "AIServiceFactory")
    
    func createService(provider: AIProvider) -> any AIGenerationService {
        logger.info("Creating AI service: \(provider.rawValue)")
        
        switch provider {
        case .falAI:
            return FalAIService()
        case .dalle:
            return FalAIService() // Fallback to FalAI for now
        case .stable:
            return FalAIService() // Fallback to FalAI for now
        }
    }
    
    func selectBestProvider() async -> AIProvider {
        // Check availability and select best option
        let falService = FalAIService()
        if await falService.isAvailable() {
            return .falAI
        }
        
        return .falAI // Default
    }
}
