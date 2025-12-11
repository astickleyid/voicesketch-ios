//
//  AIProvidersView.swift
//  VoiceSketch
//

import SwiftUI

struct AIProvidersView: View {
    @State private var falKey: String = ""
    @State private var dalleKey: String = ""
    @State private var stableKey: String = ""
    @State private var savedMessage: String?
    @State private var messageColor: Color = .green
    
    var body: some View {
        Form {
            Section(header: Text("fal.ai")) {
                SecureField("API Key", text: $falKey)
                Button("Save") {
                    Task {
                        do {
                            try await APIKeysStore.shared.save(apiKey: falKey, for: AIProvider.falAI.keychainKey)
                            savedMessage = "Saved fal.ai key"
                            messageColor = .green
                        } catch {
                            savedMessage = "Failed to save fal.ai key"
                            messageColor = .red
                        }
                    }
                }
            }
            
            Section(header: Text("DALL·E")) {
                SecureField("API Key", text: $dalleKey)
                Button("Save") {
                    Task {
                        do {
                            try await APIKeysStore.shared.save(apiKey: dalleKey, for: AIProvider.dalle.keychainKey)
                            savedMessage = "Saved DALL·E key"
                            messageColor = .green
                        } catch {
                            savedMessage = "Failed to save DALL·E key"
                            messageColor = .red
                        }
                    }
                }
            }
            
            Section(header: Text("Stable Diffusion")) {
                SecureField("API Key", text: $stableKey)
                Button("Save") {
                    Task {
                        do {
                            try await APIKeysStore.shared.save(apiKey: stableKey, for: AIProvider.stable.keychainKey)
                            savedMessage = "Saved Stable Diffusion key"
                            messageColor = .green
                        } catch {
                            savedMessage = "Failed to save Stable Diffusion key"
                            messageColor = .red
                        }
                    }
                }
            }
            
            if let message = savedMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(messageColor)
            }
        }
        .task {
            if let key = await APIKeysStore.shared.getKey(for: AIProvider.falAI.keychainKey) {
                falKey = key
            }
            if let key = await APIKeysStore.shared.getKey(for: AIProvider.dalle.keychainKey) {
                dalleKey = key
            }
            if let key = await APIKeysStore.shared.getKey(for: AIProvider.stable.keychainKey) {
                stableKey = key
            }
        }
        .navigationTitle("AI Providers")
    }
}
