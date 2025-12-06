//
//  EditView.swift
//  VoiceSketch
//

import SwiftUI
import SwiftData

struct EditView: View {
    let artwork: Artwork
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = EditViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                // Current Image
                currentImageSection
                
                // Edit State
                editStateView
                
                Spacer()
                
                // Controls
                controls
            }
            .padding()
            .background(Theme.Colors.background)
            .navigationTitle("Edit Artwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var currentImageSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Current Artwork")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.secondaryText)
            
            AsyncImage(url: artwork.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 250)
            .cornerRadius(Theme.CornerRadius.lg)
        }
    }
    
    @ViewBuilder
    private var editStateView: some View {
        switch viewModel.state {
        case .idle:
            idleView
        case .listening:
            listeningView
        case .processing:
            processingView
        case .generating(let progress):
            generatingView(progress: progress)
        case .complete:
            completeView
        case .error(let message):
            errorView(message: message)
        }
    }
    
    private var idleView: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "mic.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(Theme.Colors.primary)
            
            Text("Make Changes with Your Voice")
                .font(Theme.Typography.title3)
            
            Text("Try: 'Add a tree' or 'Make it more colorful'")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var listeningView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            WaveformVisualizer()
                .frame(height: 80)
            
            Text(viewModel.transcript.isEmpty ? "Listening..." : viewModel.transcript)
                .font(Theme.Typography.body)
                .multilineTextAlignment(.center)
        }
    }
    
    private var processingView: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Processing your edit...")
                .font(Theme.Typography.body)
        }
    }
    
    private func generatingView(progress: Double) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView(value: progress)
                .scaleEffect(1.2)
            
            Text("Applying changes...")
                .font(Theme.Typography.body)
            
            Text("\(Int(progress * 100))%")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryText)
        }
        .padding()
    }
    
    private var completeView: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Theme.Colors.success)
            
            Text("Edit Complete!")
                .font(Theme.Typography.title2)
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(Theme.Colors.error)
            
            Text(message)
                .font(Theme.Typography.body)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var controls: some View {
        VStack(spacing: Theme.Spacing.md) {
            if viewModel.state == .idle {
                Button(action: startEditing) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Start Voice Edit")
                    }
                    .font(Theme.Typography.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.CornerRadius.md)
                }
            } else if viewModel.state == .listening {
                Button(action: stopEditing) {
                    HStack {
                        Image(systemName: "stop.circle.fill")
                        Text("Stop")
                    }
                    .font(Theme.Typography.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.Colors.error)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.CornerRadius.md)
                }
            }
            
            // Quick Edit Suggestions
            if viewModel.state == .idle {
                quickEditButtons
            }
        }
    }
    
    private var quickEditButtons: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Quick Edits")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    QuickEditButton(label: "More dramatic", icon: "sparkles")
                    QuickEditButton(label: "Add sunset", icon: "sunset")
                    QuickEditButton(label: "More colorful", icon: "paintpalette")
                    QuickEditButton(label: "Add clouds", icon: "cloud")
                }
            }
        }
    }
    
    private func startEditing() {
        Task {
            await viewModel.startVoiceEdit(artwork: artwork, context: modelContext)
        }
    }
    
    private func stopEditing() {
        viewModel.stopListening()
    }
}

struct QuickEditButton: View {
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.caption)
            Text(label)
                .font(Theme.Typography.caption)
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .background(Theme.Colors.secondaryBackground)
        .foregroundColor(Theme.Colors.primary)
        .cornerRadius(Theme.CornerRadius.sm)
    }
}

@MainActor
class EditViewModel: ObservableObject {
    enum EditState: Equatable {
        case idle
        case listening
        case processing
        case generating(progress: Double)
        case complete
        case error(String)
    }
    
    @Published var state: EditState = .idle
    @Published var transcript: String = ""
    
    private let voiceService = VoiceRecognitionService()
    private let logger = AppLogger(category: "EditVM")
    
    func startVoiceEdit(artwork: Artwork, context: ModelContext) async {
        logger.info("Starting voice edit")
        state = .listening
        
        do {
            let transcriptStream = try await voiceService.startListening()
            
            for await partialTranscript in transcriptStream {
                transcript = partialTranscript
            }
            
            state = .processing
            try await Task.sleep(nanoseconds: 300_000_000)
            
            // Apply edit (simplified for now)
            await applyEdit(to: artwork, context: context)
            
        } catch {
            logger.error("Edit failed", error: error)
            state = .error(error.localizedDescription)
        }
    }
    
    func stopListening() {
        Task {
            await voiceService.stopListening()
            state = .idle
        }
    }
    
    private func applyEdit(to artwork: Artwork, context: ModelContext) async {
        state = .generating(progress: 0)
        
        // Simulate progress
        for i in 1...10 {
            try? await Task.sleep(nanoseconds: 200_000_000)
            state = .generating(progress: Double(i) / 10.0)
        }
        
        // Record edit in history
        let edit = EditRecord(
            timestamp: Date(),
            voiceCommand: transcript,
            previousImageURL: artwork.imageURL
        )
        artwork.editHistory.append(edit)
        artwork.modifiedAt = Date()
        
        try? context.save()
        
        state = .complete
        HapticManager.shared.success()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Artwork.self, configurations: config)
    
    let artwork = Artwork(
        id: UUID(),
        prompt: "Test",
        imageURL: URL(fileURLWithPath: "/tmp/test.png"),
        style: .photorealistic,
        createdAt: Date(),
        modifiedAt: Date(),
        originalPrompt: "Test",
        editHistory: [],
        thumbnail: nil,
        isFavorite: false,
        tags: [],
        generationMetadata: GenerationMetadata(
            provider: .falAI,
            model: "test",
            seed: nil,
            generationTimeMs: 150,
            cost: 0.002
        )
    )
    
    return EditView(artwork: artwork)
        .modelContainer(container)
}
