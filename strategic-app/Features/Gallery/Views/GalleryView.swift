//
//  GalleryView.swift
//  VoiceSketch
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Artwork.createdAt, order: .reverse) private var artworks: [Artwork]
    
    @State private var selectedArtwork: Artwork?
    @State private var showingDetail = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: Theme.Spacing.md)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                if artworks.isEmpty {
                    emptyState
                } else {
                    galleryGrid
                }
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.sortOrder = .newest
                        } label: {
                            Label("Newest First", systemImage: "arrow.down")
                        }
                        
                        Button {
                            viewModel.sortOrder = .oldest
                        } label: {
                            Label("Oldest First", systemImage: "arrow.up")
                        }
                        
                        Button {
                            viewModel.sortOrder = .favorites
                        } label: {
                            Label("Favorites", systemImage: "heart.fill")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showingDetail) {
                if let artwork = selectedArtwork {
                    ArtworkDetailView(artwork: artwork)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "photo.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Text("No Artworks Yet")
                .font(Theme.Typography.title2)
            
            Text("Create your first artwork using your voice")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var galleryGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                ForEach(filteredArtworks) { artwork in
                    ArtworkGridItem(artwork: artwork)
                        .onTapGesture {
                            selectedArtwork = artwork
                            showingDetail = true
                        }
                        .contextMenu {
                            Button {
                                toggleFavorite(artwork)
                            } label: {
                                Label(
                                    artwork.isFavorite ? "Unfavorite" : "Favorite",
                                    systemImage: artwork.isFavorite ? "heart.slash" : "heart"
                                )
                            }
                            
                            Button(role: .destructive) {
                                deleteArtwork(artwork)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }
    
    private var filteredArtworks: [Artwork] {
        switch viewModel.sortOrder {
        case .newest:
            return artworks
        case .oldest:
            return artworks.reversed()
        case .favorites:
            return artworks.filter { $0.isFavorite }
        }
    }
    
    private func toggleFavorite(_ artwork: Artwork) {
        artwork.isFavorite.toggle()
        try? modelContext.save()
        HapticManager.shared.impact(.light)
    }
    
    private func deleteArtwork(_ artwork: Artwork) {
        modelContext.delete(artwork)
        try? modelContext.save()
        HapticManager.shared.impact(.medium)
    }
}

struct ArtworkGridItem: View {
    let artwork: Artwork
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .fill(Theme.Colors.secondaryBackground)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ProgressView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
            
            if artwork.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .padding(8)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        let cache = ImageCacheService()
        image = await cache.image(for: artwork.imageURL)
    }
}

@MainActor
class GalleryViewModel: ObservableObject {
    enum SortOrder {
        case newest, oldest, favorites
    }
    
    @Published var sortOrder: SortOrder = .newest
}

#Preview {
    GalleryView()
        .modelContainer(for: Artwork.self, inMemory: true)
}
