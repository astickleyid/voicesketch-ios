//
//  SubscriptionView.swift
//  VoiceSketch
//

import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: SubscriptionTier = .pro
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    header
                    
                    // Features
                    features
                    
                    // Pricing Tiers
                    pricingTiers
                    
                    // CTA
                    ctaButton
                    
                    // Footer
                    footer
                }
                .padding()
            }
            .background(Theme.Colors.background)
            .navigationTitle("Go Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "crown.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(
                    .linearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Unlock Unlimited Creativity")
                .font(Theme.Typography.largeTitle)
                .multilineTextAlignment(.center)
            
            Text("Create without limits")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.secondaryText)
        }
    }
    
    private var features: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            FeatureRow(
                icon: "infinity",
                title: "Unlimited Generations",
                description: "Create as many artworks as you want"
            )
            
            FeatureRow(
                icon: "paintbrush.fill",
                title: "All Art Styles",
                description: "Access to all 12+ professional styles"
            )
            
            FeatureRow(
                icon: "sparkles",
                title: "No Watermarks",
                description: "Export clean, professional images"
            )
            
            FeatureRow(
                icon: "bolt.fill",
                title: "Priority Generation",
                description: "Faster AI processing"
            )
            
            FeatureRow(
                icon: "icloud.fill",
                title: "Cloud Sync",
                description: "Access your art across devices"
            )
            
            FeatureRow(
                icon: "square.and.arrow.up",
                title: "HD Export",
                description: "Download in highest quality"
            )
        }
        .padding()
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }
    
    private var pricingTiers: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Monthly
            SubscriptionCard(
                tier: .pro,
                isSelected: selectedTier == .pro
            ) {
                selectedTier = .pro
            }
            
            // Yearly (with badge)
            ZStack(alignment: .topTrailing) {
                SubscriptionCard(
                    tier: .proYearly,
                    isSelected: selectedTier == .proYearly
                ) {
                    selectedTier = .proYearly
                }
                
                Text("SAVE 33%")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.success)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .offset(x: -8, y: -8)
            }
        }
    }
    
    private var ctaButton: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Button(action: purchase) {
                Text("Start 7-Day Free Trial")
                    .font(Theme.Typography.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.CornerRadius.md)
            }
            
            Button("Restore Purchases") {
                restore()
            }
            .font(Theme.Typography.caption)
            .foregroundColor(Theme.Colors.secondaryText)
        }
    }
    
    private var footer: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("7-day free trial, then \(selectedTier.price)")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Text("Cancel anytime. Auto-renews monthly.")
                .font(Theme.Typography.caption2)
                .foregroundColor(Theme.Colors.secondaryText)
        }
        .multilineTextAlignment(.center)
    }
    
    private func purchase() {
        // TODO: Implement StoreKit 2 purchase
        HapticManager.shared.success()
    }
    
    private func restore() {
        // TODO: Implement restore purchases
        HapticManager.shared.impact()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Typography.headline)
                
                Text(description)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
        }
    }
}

struct SubscriptionCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tier.displayName)
                        .font(Theme.Typography.headline)
                    
                    Text(tier.price)
                        .font(Theme.Typography.title2)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.secondaryText)
                    .font(.title2)
            }
            .padding()
            .background(isSelected ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(isSelected ? Theme.Colors.primary : .clear, lineWidth: 2)
            )
            .cornerRadius(Theme.CornerRadius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum SubscriptionTier {
    case free
    case pro
    case proYearly
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro Monthly"
        case .proYearly: return "Pro Yearly"
        }
    }
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .pro: return "$9.99/month"
        case .proYearly: return "$79.99/year"
        }
    }
}

#Preview {
    SubscriptionView()
}
