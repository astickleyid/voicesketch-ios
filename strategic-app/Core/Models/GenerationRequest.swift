//
//  GenerationRequest.swift
//  VoiceSketch
//

import Foundation

struct GenerationRequest: Sendable {
    let prompt: String
    let style: ArtStyle
    let provider: AIProvider
    let seed: Int?
    let quality: ImageQuality
    
    init(
        prompt: String,
        style: ArtStyle,
        provider: AIProvider = .falAI,
        seed: Int? = nil,
        quality: ImageQuality = .high
    ) {
        self.prompt = prompt
        self.style = style
        self.provider = provider
        self.seed = seed
        self.quality = quality
    }
    
    var enhancedPrompt: String {
        "\(prompt), \(style.promptSuffix)"
    }
}

enum ImageQuality: String, Codable, Sendable {
    case standard = "standard"
    case high = "high"
    case ultra = "ultra"
    
    var dimensions: (width: Int, height: Int) {
        switch self {
        case .standard: return (512, 512)
        case .high: return (768, 768)
        case .ultra: return (1024, 1024)
        }
    }
}
