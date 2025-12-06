//
//  ArtworkDetailView.swift
//  VoiceSketch
//

import SwiftUI
import SwiftData

struct ArtworkDetailView: View {
    let artwork: Artwork
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var image: UIImage?
    @State private var showingShareSheet = false
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Main Image
                    imageSection
                    
                    // Details
                    detailsSection
                    
                    // Metadata
                    metadataSection
                    
                    // Actions
                    actionsSection
                }
                .padding()
            }
            .background(Theme.Colors.background)
            .navigationTitle("Artwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            toggleFavorite()
                        } label: {
                            Label(
                                artwork.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: artwork.isFavorite ? "heart.slash.fill" : "heart"
                            )
                        }
                        
                        Button {
                            showingShareSheet = true
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "wand.and.stars")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            deleteArtwork()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = image {
                    ShareSheet(items: [image])
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditView(artwork: artwork)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private var imageSection: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(Theme.CornerRadius.lg)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            } else {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .fill(Theme.Colors.secondaryBackground)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        ProgressView()
                    }
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Prompt")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Text(artwork.prompt)
                .font(Theme.Typography.body)
            
            HStack {
                Label(artwork.style.rawValue, systemImage: "paintbrush.fill")
                    .font(Theme.Typography.caption)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(artwork.style.color.opacity(0.2))
                    .foregroundColor(artwork.style.color)
                    .cornerRadius(Theme.CornerRadius.sm)
                
                Spacer()
                
                if artwork.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Details")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.secondaryText)
            
            VStack(spacing: Theme.Spacing.sm) {
                MetadataRow(
                    icon: "calendar",
                    label: "Created",
                    value: artwork.createdAt.formatted(date: .abbreviated, time: .shortened)
                )
                
                MetadataRow(
                    icon: "clock",
                    label: "Generation Time",
                    value: "\(artwork.generationMetadata.generationTimeMs)ms"
                )
                
                MetadataRow(
                    icon: "cpu",
                    label: "Provider",
                    value: artwork.generationMetadata.provider.rawValue
                )
                
                if let cost = artwork.generationMetadata.cost {
                    MetadataRow(
                        icon: "dollarsign.circle",
                        label: "Cost",
                        value: "$\(cost)"
                    )
                }
            }
        }
        .padding()
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.md)
    }
    
    private var actionsSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            Button(action: { showingEditSheet = true }) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Edit with Voice")
                }
                .font(Theme.Typography.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(Theme.CornerRadius.md)
            }
            
            Button(action: { showingShareSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Artwork")
                }
                .font(Theme.Typography.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.Colors.secondaryBackground)
                .foregroundColor(Theme.Colors.primary)
                .cornerRadius(Theme.CornerRadius.md)
            }
        }
    }
    
    private func loadImage() async {
        let cache = ImageCacheService()
        image = await cache.image(for: artwork.imageURL)
    }
    
    private func toggleFavorite() {
        artwork.isFavorite.toggle()
        try? modelContext.save()
        HapticManager.shared.impact()
    }
    
    private func deleteArtwork() {
        modelContext.delete(artwork)
        try? modelContext.save()
        dismiss()
    }
}

struct MetadataRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.callout)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Artwork.self, configurations: config)
    
    let artwork = Artwork(
        id: UUID(),
        prompt: "A beautiful sunset over mountains",
        imageURL: URL(fileURLWithPath: "/tmp/test.png"),
        style: .watercolor,
        createdAt: Date(),
        modifiedAt: Date(),
        originalPrompt: "Draw a sunset",
        editHistory: [],
        thumbnail: nil as Data?,
        isFavorite: true,
        tags: ["sunset", "mountains"],
        generationMetadata: GenerationMetadata(
            provider: .falAI,
            model: "fast-lcm",
            seed: 12345,
            generationTimeMs: 150,
            cost: 0.002
        )
    )
    
    ArtworkDetailView(artwork: artwork)
        .modelContainer(container)
}
