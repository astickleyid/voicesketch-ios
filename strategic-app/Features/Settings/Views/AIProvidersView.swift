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
    @State private var hasFalKey = false
    @State private var hasDalleKey = false
    @State private var hasStableKey = false
    
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
                            hasFalKey = true
                            falKey = ""
                        } catch {
                            savedMessage = "Failed to save fal.ai key"
                            messageColor = .red
                        }
                    }
                }
                if hasFalKey {
                    Label("Key saved", systemImage: "checkmark.shield")
                        .font(.caption)
                        .foregroundColor(.green)
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
                            hasDalleKey = true
                            dalleKey = ""
                        } catch {
                            savedMessage = "Failed to save DALL·E key"
                            messageColor = .red
                        }
                    }
                }
                if hasDalleKey {
                    Label("Key saved", systemImage: "checkmark.shield")
                        .font(.caption)
                        .foregroundColor(.green)
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
                            hasStableKey = true
                            stableKey = ""
                        } catch {
                            savedMessage = "Failed to save Stable Diffusion key"
                            messageColor = .red
                        }
                    }
                }
                if hasStableKey {
                    Label("Key saved", systemImage: "checkmark.shield")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            if let message = savedMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(messageColor)
            }
        }
        .task {
            hasFalKey = await APIKeysStore.shared.getKey(for: AIProvider.falAI.keychainKey) != nil
            hasDalleKey = await APIKeysStore.shared.getKey(for: AIProvider.dalle.keychainKey) != nil
            hasStableKey = await APIKeysStore.shared.getKey(for: AIProvider.stable.keychainKey) != nil
        }
        .onChange(of: falKey) { _ in savedMessage = nil }
        .onChange(of: dalleKey) { _ in savedMessage = nil }
        .onChange(of: stableKey) { _ in savedMessage = nil }
        .onChange(of: savedMessage) { message in
            guard message != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                savedMessage = nil
            }
        }
        .onDisappear {
            falKey = ""
            dalleKey = ""
            stableKey = ""
        }
        .navigationTitle("AI Providers")
    }
}
