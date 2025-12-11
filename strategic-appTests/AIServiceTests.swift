//
//  AIServiceTests.swift
//  strategic-appTests
//

import XCTest
@testable import strategic_app

final class AIServiceTests: XCTestCase {
    
    func testUnsupportedProviderMessageMentionsSettingsPath() async {
        let service = UnsupportedAIService(provider: .dalle)
        let request = GenerationRequest(prompt: "test", style: .photorealistic, provider: .dalle, quality: .standard)
        
        do {
            _ = try await service.generate(request)
            XCTFail("Expected unsupported provider error")
        } catch {
            let message = (error as NSError).localizedDescription
            XCTAssertTrue(message.contains("Settings > AI Configuration > AI Providers"))
        }
    }
    
    func testAPIKeysStoreSaveGetDelete() async throws {
        let provider = "unit-test-provider-\(UUID().uuidString)"
        let store = APIKeysStore.shared
        
        try await store.save(apiKey: "test-key", for: provider)
        let fetched = await store.getKey(for: provider)
        XCTAssertEqual(fetched, "test-key")
        
        try await store.deleteKey(for: provider)
        let deleted = await store.getKey(for: provider)
        XCTAssertNil(deleted)
    }
}
