//
//  FalAIService.swift
//  VoiceSketch
//

import Foundation

/// fal.ai LCM API implementation
actor FalAIService: AIGenerationService {
    private let logger = AppLogger(category: "FalAIService")
    private let apiKey: String
    private let endpoint = "https://fal.run/fal-ai/fast-lcm-diffusion"
    
    init() {
        // In production, load from secure storage or config
        self.apiKey = ProcessInfo.processInfo.environment["FAL_API_KEY"] ?? ""
    }
    
    func generate(_ request: GenerationRequest) async throws -> Data {
        logger.info("Generating image: \(request.prompt)")
        
        guard !apiKey.isEmpty else {
            throw VoiceSketchError.apiError(underlying: NSError(
                domain: "FalAI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "API key not configured"]
            ))
        }
        
        // Build request
        let dimensions = request.quality.dimensions
        let payload: [String: Any] = [
            "prompt": request.enhancedPrompt,
            "image_size": [
                "width": dimensions.width,
                "height": dimensions.height
            ],
            "num_inference_steps": 4, // LCM is optimized for 4-8 steps
            "guidance_scale": 1.0,
            "seed": request.seed ?? Int.random(in: 0...999999)
        ]
        
        // Create URL request
        guard let url = URL(string: endpoint) else {
            throw VoiceSketchError.invalidPrompt
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        // Execute request with retry
        let imageData = try await executeWithRetry(urlRequest)
        
        logger.info("Generation complete")
        return imageData
    }
    
    func isAvailable() async -> Bool {
        !apiKey.isEmpty
    }
    
    func estimatedCost(for quality: ImageQuality) -> Decimal {
        // fal.ai LCM pricing
        switch quality {
        case .standard: return 0.001
        case .high: return 0.002
        case .ultra: return 0.003
        }
    }
    
    // MARK: - Private Helpers
    
    private func executeWithRetry(_ request: URLRequest, maxAttempts: Int = 3) async throws -> Data {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw VoiceSketchError.apiError(underlying: NSError(
                        domain: "FalAI",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid response"]
                    ))
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 429 {
                        throw VoiceSketchError.quotaExceeded
                    }
                    throw VoiceSketchError.apiError(underlying: NSError(
                        domain: "FalAI",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"]
                    ))
                }
                
                // Parse response
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                // Extract image URL or data
                if let imageURLString = json?["images"] as? [[String: Any]],
                   let firstImage = imageURLString.first,
                   let urlString = firstImage["url"] as? String,
                   let imageURL = URL(string: urlString) {
                    // Download image
                    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
                    return imageData
                }
                
                throw VoiceSketchError.imageProcessingFailed
                
            } catch {
                lastError = error
                logger.warning("Attempt \(attempt) failed: \(error.localizedDescription)")
                
                if attempt < maxAttempts {
                    // Exponential backoff
                    let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                    try await Task.sleep(nanoseconds: delay)
                }
            }
        }
        
        throw VoiceSketchError.apiError(underlying: lastError!)
    }
}
