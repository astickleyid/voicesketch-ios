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
    
    func createService(provider: AIProvider) async -> any AIGenerationService {
        logger.info("Creating AI service: \(provider.rawValue)")
        
        switch provider {
        case .falAI:
            let key = await APIKeysStore.shared.getKey(for: provider.rawValue) ?? ""
            return FalAIService(apiKey: key)
        case .dalle:
            let key = await APIKeysStore.shared.getKey(for: "dalle") ?? ""
            return FalAIService(apiKey: key) // Fallback to FalAI for now
        case .stable:
            let key = await APIKeysStore.shared.getKey(for: "stable") ?? ""
            return FalAIService(apiKey: key) // Fallback to FalAI for now
        }
    }
    
    func selectBestProvider() async -> AIProvider {
        let falKey = await APIKeysStore.shared.getKey(for: AIProvider.falAI.rawValue) ?? ""
        if !falKey.isEmpty {
            return .falAI
        }
        return .falAI
    }
}
