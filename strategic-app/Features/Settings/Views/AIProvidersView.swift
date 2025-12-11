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
    
    var body: some View {
        Form {
            Section(header: Text("fal.ai")) {
                SecureField("API Key", text: $falKey)
                Button("Save") {
                    Task {
                        try? await APIKeysStore.shared.save(apiKey: falKey, for: AIProvider.falAI.rawValue)
                        savedMessage = "Saved fal.ai key"
                    }
                }
            }
            
            Section(header: Text("DALL·E")) {
                SecureField("API Key", text: $dalleKey)
                Button("Save") {
                    Task {
                        try? await APIKeysStore.shared.save(apiKey: dalleKey, for: "dalle")
                        savedMessage = "Saved DALL·E key"
                    }
                }
            }
            
            Section(header: Text("Stable Diffusion")) {
                SecureField("API Key", text: $stableKey)
                Button("Save") {
                    Task {
                        try? await APIKeysStore.shared.save(apiKey: stableKey, for: "stable")
                        savedMessage = "Saved Stable Diffusion key"
                    }
                }
            }
            
            if let message = savedMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .task {
            if let key = await APIKeysStore.shared.getKey(for: AIProvider.falAI.rawValue) {
                falKey = key
            }
            if let key = await APIKeysStore.shared.getKey(for: "dalle") {
                dalleKey = key
            }
            if let key = await APIKeysStore.shared.getKey(for: "stable") {
                stableKey = key
            }
        }
        .navigationTitle("AI Providers")
    }
}
