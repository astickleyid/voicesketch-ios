//
//  CreationViewModel.swift
//  VoiceSketch
//

import SwiftUI
import SwiftData

/// Generation states
enum GenerationState: Equatable {
    case idle
    case listening
    case processing
    case generating(progress: Double)
    case revealing
    case complete(UUID) // Artwork ID
    case error(String)
}

/// ViewModel for creation flow
@MainActor
final class CreationViewModel: ObservableObject {
    @Published var state: GenerationState = .idle
    @Published var transcript: String = ""
    @Published var selectedStyle: ArtStyle = .photorealistic
    
    private let voiceService = VoiceRecognitionService()
    private let haptics = HapticManager.shared
    private let logger = AppLogger(category: "CreationVM")
    
    private var generationTask: Task<Void, Never>?
    
    /// Start voice creation flow
    func startVoiceCreation(context: ModelContext) async {
        logger.info("Starting voice creation")
        
        state = .listening
        transcript = ""
        
        haptics.prepare()
        haptics.impact()
        
        do {
            let transcriptStream = try await voiceService.startListening()
            
            for await partialTranscript in transcriptStream {
                transcript = partialTranscript
            }
            
            // Processing
            state = .processing
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3s dramatic pause
            
            // Generate
            await generate(context: context)
            
        } catch {
            logger.error("Voice creation failed", error: error)
            state = .error(error.localizedDescription)
            haptics.error()
        }
    }
    
    /// Stop listening
    func stopListening() {
        Task {
            await voiceService.stopListening()
        }
    }
    
    /// Generate from current transcript
    private func generate(context: ModelContext) async {
        guard !transcript.isEmpty else {
            state = .error("No voice input detected")
            return
        }
        
        state = .generating(progress: 0)
        
        // Simulate progress for UX
        generationTask = Task {
            for i in 1...10 {
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
                guard !Task.isCancelled else { return }
                state = .generating(progress: Double(i) / 10.0)
            }
        }
        
        do {
            // Create services
            let factory = AIServiceFactory()
            let provider = await factory.selectBestProvider()
            let aiService = await factory.createService(provider: provider)
            let imageCache = ImageCacheService()
            let useCase = GenerateArtworkUseCase(aiService: aiService, imageCache: imageCache, provider: provider)
            
            // Execute generation
            let artwork = try await useCase.execute(transcript: transcript, context: context)
            
            // Cancel progress simulation
            generationTask?.cancel()
            
            // Reveal animation
            state = .revealing
            haptics.success()
            
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            
            state = .complete(artwork.id)
            logger.info("Generation complete")
            
        } catch {
            generationTask?.cancel()
            logger.error("Generation failed", error: error)
            state = .error(error.localizedDescription)
            haptics.error()
        }
    }
    
    /// Reset to idle
    func reset() {
        state = .idle
        transcript = ""
        generationTask?.cancel()
    }
}
