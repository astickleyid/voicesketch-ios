//
//  CreationView.swift
//  VoiceSketch
//

import SwiftUI
import SwiftData

struct CreationView: View {
    @StateObject private var viewModel = CreationViewModel()
    @Environment(\.modelContext) private var modelContext
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack {
                header
                Spacer()
                stateView
                Spacer()
                controls
            }
            .padding()
        }
        .animation(Theme.Animation.spring, value: viewModel.state)
    }
    
    private var header: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("VoiceSketch")
                .font(Theme.Typography.largeTitle)
            
            Text("Speak your imagination")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.secondaryText)
        }
    }
    
    @ViewBuilder
    private var stateView: some View {
        switch viewModel.state {
        case .idle:
            idleView
        case .listening:
            listeningView
        case .processing:
            processingView
        case .generating(let progress):
            generatingView(progress: progress)
        case .revealing:
            revealingView
        case .complete(let artworkID):
            completeView(artworkID: artworkID)
        case .error(let message):
            errorView(message: message)
        }
    }
    
    private var idleView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "mic.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Theme.Colors.primary)
            
            Text("Tap to start creating")
                .font(Theme.Typography.title3)
        }
    }
    
    private var listeningView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            WaveformVisualizer()
                .frame(height: 100)
            
            Text(viewModel.transcript.isEmpty ? "Listening..." : viewModel.transcript)
                .font(Theme.Typography.body)
                .multilineTextAlignment(.center)
                .padding()
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private var processingView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Processing...")
                .font(Theme.Typography.body)
        }
    }
    
    private func generatingView(progress: Double) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            ZStack {
                GenerationOverlayView(isActive: .constant(true), cornerRadius: Theme.CornerRadius.lg)
                    .frame(width: 300, height: 300)
                    .allowsHitTesting(false)
                
                ProgressView(value: progress)
                    .padding()
            }
            .frame(width: 300, height: 300)
            
            Text("Creating your artwork...")
                .font(Theme.Typography.body)
            
            Text("\(Int(progress * 100))%")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryText)
        }
        .matchedGeometryEffect(id: "canvas", in: animation)
    }
    
    private var revealingView: some View {
        ProgressView().scaleEffect(1.5)
    }
    
    private func completeView(artworkID: UUID) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Theme.Colors.success)
            
            Text("Artwork Created!")
                .font(Theme.Typography.title2)
            
            Button("View in Gallery") {
                viewModel.reset()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Theme.Colors.error)
            
            Text(message)
                .font(Theme.Typography.body)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                viewModel.reset()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
    
    private var controls: some View {
        HStack(spacing: Theme.Spacing.lg) {
            if viewModel.state == .idle {
                Button(action: startCreation) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Start Creating")
                    }
                    .font(Theme.Typography.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.CornerRadius.md)
                }
            } else if viewModel.state == .listening {
                Button(action: stopCreation) {
                    HStack {
                        Image(systemName: "stop.circle.fill")
                        Text("Stop")
                    }
                    .font(Theme.Typography.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.Colors.error)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.CornerRadius.md)
                }
            }
        }
    }
    
    private func startCreation() {
        Task {
            await viewModel.startVoiceCreation(context: modelContext)
        }
    }
    
    private func stopCreation() {
        viewModel.stopListening()
        viewModel.reset()
    }
}

struct WaveformVisualizer: View {
    @State private var amplitudes: [CGFloat] = Array(repeating: 0.3, count: 40)
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<amplitudes.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.Colors.primary)
                    .frame(width: 4, height: amplitudes[index] * 100)
            }
        }
        .onAppear { animateWaveform() }
    }
    
    private func animateWaveform() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                for index in 0..<amplitudes.count {
                    amplitudes[index] = CGFloat.random(in: 0.2...0.8)
                }
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
    }
}
