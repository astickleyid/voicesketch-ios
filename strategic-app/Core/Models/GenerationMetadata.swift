//
//  GenerationMetadata.swift
//  VoiceSketch
//
//  Created on 2025-12-04
//

import Foundation

/// Metadata about how an artwork was generated
struct GenerationMetadata: Codable, Hashable, Sendable {
    /// AI provider used for generation
    let provider: AIProvider
    
    /// Specific model name/version
    let model: String
    
    /// Random seed for reproducibility (if available)
    let seed: Int?
    
    /// Generation time in milliseconds
    let generationTimeMs: Int
    
    /// Cost in USD (if tracked)
    let cost: Decimal?
    
    /// Additional parameters used
    let parameters: [String: String]?
    
    init(
        provider: AIProvider,
        model: String,
        seed: Int? = nil,
        generationTimeMs: Int,
        cost: Decimal? = nil,
        parameters: [String: String]? = nil
    ) {
        self.provider = provider
        self.model = model
        self.seed = seed
        self.generationTimeMs = generationTimeMs
        self.cost = cost
        self.parameters = parameters
    }
}

#if false // AIProvider is defined elsewhere in the project; avoid redeclaration here.
/// AI provider options (fallback; disabled to prevent duplicate symbol)
enum AIProvider: String, Codable, Sendable {
    case falAI = "fal.ai"
    case dalleThree = "DALL-E 3"
    case stableDiffusion = "Stable Diffusion"
    case midjourney = "Midjourney"
    
    var displayName: String { rawValue }
}
#endif
