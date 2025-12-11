//
//  GenerateArtworkUseCase.swift
//  VoiceSketch
//

import Foundation
import SwiftData

/// Use case for generating artwork from voice commands
actor GenerateArtworkUseCase {
    private let logger = AppLogger(category: "GenerateArtwork")
    private let aiService: any AIGenerationService
    private let imageCache: ImageCacheService
    private let provider: AIProvider
    private let parser = VoiceCommandParser()
    
    init(aiService: any AIGenerationService, imageCache: ImageCacheService, provider: AIProvider) {
        self.aiService = aiService
        self.imageCache = imageCache
        self.provider = provider
    }
    
    /// Execute generation from voice command
    func execute(transcript: String, context: ModelContext) async throws -> Artwork {
        logger.info("Starting generation from transcript")
        
        // 1. Parse voice command
        let command = parser.parse(transcript)
        
        guard case .create(let description, let style) = command.intent else {
            throw VoiceSketchError.invalidPrompt
        }
        
        guard command.confidence > 0.5 else {
            logger.warning("Low confidence: \(command.confidence)")
            throw VoiceSketchError.voiceRecognitionFailed
        }
        
        // 2. Create generation request
        let selectedStyle = style ?? .photorealistic
        let request = GenerationRequest(
            prompt: description,
            style: selectedStyle,
            provider: provider,
            quality: .high
        )
        
        logger.info("Generating: \(request.enhancedPrompt)")
        
        // 3. Generate image
        let startTime = Date()
        let imageData = try await aiService.generate(request)
        let generationTime = Int(Date().timeIntervalSince(startTime) * 1000)
        
        // 4. Save to cache
        let imageURL = try await imageCache.save(imageData)
        
        // 5. Generate thumbnail
        let thumbnail = await imageCache.generateThumbnail(for: imageURL)
        
        // 6. Create artwork model
        let artwork = Artwork(
            id: UUID(),
            prompt: description,
            imageURL: imageURL,
            style: selectedStyle,
            createdAt: Date(),
            modifiedAt: Date(),
            originalPrompt: transcript,
            editHistory: [],
            thumbnail: thumbnail,
            isFavorite: false,
            tags: extractTags(from: description),
            generationMetadata: GenerationMetadata(
                provider: provider,
                model: "fast-lcm-diffusion",
                seed: request.seed,
                generationTimeMs: generationTime,
                cost: await aiService.estimatedCost(for: request.quality)
            )
        )
        
        // 7. Save to SwiftData
        context.insert(artwork)
        try context.save()
        
        logger.info("Generation complete: \(artwork.id)")
        return artwork
    }
    
    /// Execute generation from direct prompt (no voice)
    func execute(prompt: String, style: ArtStyle, context: ModelContext) async throws -> Artwork {
        logger.info("Starting generation from prompt")
        
        let request = GenerationRequest(
            prompt: prompt,
            style: style,
            provider: provider,
            quality: .high
        )
        
        let startTime = Date()
        let imageData = try await aiService.generate(request)
        let generationTime = Int(Date().timeIntervalSince(startTime) * 1000)
        
        let imageURL = try await imageCache.save(imageData)
        let thumbnail = await imageCache.generateThumbnail(for: imageURL)
        
        let artwork = Artwork(
            id: UUID(),
            prompt: prompt,
            imageURL: imageURL,
            style: style,
            createdAt: Date(),
            modifiedAt: Date(),
            originalPrompt: prompt,
            editHistory: [],
            thumbnail: thumbnail,
            isFavorite: false,
            tags: extractTags(from: prompt),
            generationMetadata: GenerationMetadata(
                provider: provider,
                model: "fast-lcm-diffusion",
                seed: request.seed,
                generationTimeMs: generationTime,
                cost: await aiService.estimatedCost(for: request.quality)
            )
        )
        
        context.insert(artwork)
        try context.save()
        
        logger.info("Generation complete: \(artwork.id)")
        return artwork
    }
    
    // MARK: - Private Helpers
    
    private func extractTags(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }
        
        return Array(Set(words)).prefix(5).map { $0 }
    }
}
