//
//  GenerationOverlayView.swift
//  VoiceSketch
//

import SwiftUI

/// A lightweight glassy overlay with a continuous shimmer stripe.
/// Place this behind the scribble/canvas content in a ZStack so it doesn't occlude animations.
struct GenerationOverlayView: View {
    @Binding var isActive: Bool
    var cornerRadius: CGFloat = 20
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                
                ShimmerStripe(isActive: isActive)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .allowsHitTesting(false)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .compositingGroup()
        }
    }
}

private struct ShimmerStripe: View {
    var isActive: Bool
    @State private var offsetX: CGFloat = -1.0
    
    var body: some View {
        GeometryReader { geo in
            let stripeWidth = max(geo.size.width * 0.25, 60)
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.white.opacity(0.00), location: 0),
                    .init(color: Color.white.opacity(0.12), location: 0.5),
                    .init(color: Color.white.opacity(0.00), location: 1)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: stripeWidth, height: geo.size.height * 1.2)
            .offset(x: offsetX * (geo.size.width + stripeWidth))
            .blendMode(.overlay)
            .opacity(0.9)
            .onAppear {
                guard isActive else { return }
                startAnimation()
            }
            .onChange(of: isActive) { active in
                if active {
                    startAnimation()
                } else {
                    withAnimation(.easeOut(duration: 0.25)) {
                        offsetX = -1.0
                    }
                }
            }
        }
    }
    
    private func startAnimation() {
        offsetX = 1.0
        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
            offsetX = -1.0
        }
    }
}
