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
    
    var keychainKey: String {
        switch self {
        case .falAI: return "fal.ai"
        case .dalle: return "dalle"
        case .stable: return "stable"
        }
    }
}

/// Factory for creating AI services
actor AIServiceFactory {
    private let logger = AppLogger(category: "AIServiceFactory")
    
    func createService(provider: AIProvider) async -> any AIGenerationService {
        logger.info("Creating AI service: \(provider.rawValue)")
        
        switch provider {
        case .falAI:
            let key = await falApiKey()
            return FalAIService(apiKey: key)
        case .dalle:
            return UnsupportedAIService(provider: provider)
        case .stable:
            return UnsupportedAIService(provider: provider)
        }
    }
    
    func selectBestProvider() async -> AIProvider {
        if !await falApiKey().isEmpty {
            return .falAI
        }
        if let dalleKey = await providerKey(for: .dalle), !dalleKey.isEmpty {
            return .dalle
        }
        if let stableKey = await providerKey(for: .stable), !stableKey.isEmpty {
            return .stable
        }
        return .falAI
    }
    
    private func providerKey(for provider: AIProvider) async -> String? {
        await APIKeysStore.shared.getKey(for: provider.keychainKey)
    }
    
    private func falApiKey() async -> String {
        if let stored = await providerKey(for: .falAI), !stored.isEmpty {
            return stored
        }
        return ProcessInfo.processInfo.environment["FAL_API_KEY"] ?? ""
    }
}

actor UnsupportedAIService: AIGenerationService {
    let provider: AIProvider
    
    init(provider: AIProvider) {
        self.provider = provider
    }
    
    func generate(_ request: GenerationRequest) async throws -> Data {
        throw VoiceSketchError.apiError(underlying: NSError(
            domain: provider.rawValue,
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "\(provider.displayName) requires an API key. Configure it in Settings > AI Providers."]
        ))
    }
    
    func isAvailable() async -> Bool { false }
    
    func estimatedCost(for quality: ImageQuality) -> Decimal { 0 }
}
