//
//  SettingsView.swift
//  VoiceSketch
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var artworks: [Artwork]
    @State private var showingSubscription = false
    @State private var showingClearCache = false
    @State private var cacheSize: String = "Calculating..."
    
    var body: some View {
        NavigationStack {
            List {
                // Subscription Section
                subscriptionSection
                
                // Stats Section
                statsSection
                
                // Storage Section
                storageSection
                
                // About Section
                aboutSection
            }
            .navigationTitle("Settings")
            .task {
                await calculateCacheSize()
            }
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
            .alert("Clear Cache?", isPresented: $showingClearCache) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("This will clear all cached images. Your artworks will remain safe.")
            }
        }
    }
    
    private var subscriptionSection: some View {
        Section {
            Button {
                showingSubscription = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("VoiceSketch Pro")
                            .font(Theme.Typography.headline)
                        Text("Unlimited generations")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Text("Upgrade")
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.primary)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        } header: {
            Text("Subscription")
        }
    }
    
    private var statsSection: some View {
        Section {
            StatRow(
                label: "Total Artworks",
                value: "\(artworks.count)",
                icon: "photo.stack"
            )
            
            StatRow(
                label: "Favorites",
                value: "\(artworks.filter { $0.isFavorite }.count)",
                icon: "heart.fill",
                color: .red
            )
            
            StatRow(
                label: "This Month",
                value: "\(artworksThisMonth)",
                icon: "calendar"
            )
            
            StatRow(
                label: "Total Generation Time",
                value: totalGenerationTime,
                icon: "clock"
            )
        } header: {
            Text("Statistics")
        }
    }
    
    private var storageSection: some View {
        Section {
            HStack {
                Label("Cache Size", systemImage: "internaldrive")
                Spacer()
                Text(cacheSize)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            Button {
                showingClearCache = true
            } label: {
                Label("Clear Cache", systemImage: "trash")
                    .foregroundColor(.red)
            }
        } header: {
            Text("Storage")
        } footer: {
            Text("Clearing cache will not delete your artworks")
        }
    }
    
    private var aboutSection: some View {
        Section {
            Link(destination: URL(string: "https://voicesketch.app/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            
            Link(destination: URL(string: "https://voicesketch.app/terms")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }
            
            Link(destination: URL(string: "https://voicesketch.app/support")!) {
                Label("Support", systemImage: "questionmark.circle")
            }
            
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(Theme.Colors.secondaryText)
            }
        } header: {
            Text("About")
        }
    }
    
    private var artworksThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return artworks.filter { artwork in
            calendar.isDate(artwork.createdAt, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private var totalGenerationTime: String {
        let totalMs = artworks.reduce(0) { $0 + $1.generationMetadata.generationTimeMs }
        let seconds = Double(totalMs) / 1000.0
        if seconds < 60 {
            return String(format: "%.1fs", seconds)
        } else {
            let minutes = Int(seconds / 60)
            return "\(minutes)m"
        }
    }
    
    private func calculateCacheSize() async {
        let cache = ImageCacheService()
        let size = await cache.cacheSize()
        let mb = Double(size) / 1_000_000
        cacheSize = String(format: "%.1f MB", mb)
    }
    
    private func clearCache() {
        Task {
            let cache = ImageCacheService()
            try? await cache.clearAll()
            await calculateCacheSize()
            HapticManager.shared.success()
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    var color: Color = Theme.Colors.primary
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundColor(color)
            Spacer()
            Text(value)
                .font(Theme.Typography.headline)
                .foregroundColor(color)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Artwork.self, inMemory: true)
}
