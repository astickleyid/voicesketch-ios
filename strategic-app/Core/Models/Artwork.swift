//
//  Artwork.swift
//  VoiceSketch
//
//  Created on 2025-12-04
//

import Foundation
import SwiftData

/// Represents a generated artwork with full history and metadata
@Model
final class Artwork {
    /// Unique identifier
    @Attribute(.unique) var id: UUID
    
    /// User's original voice prompt
    var prompt: String
    
    /// Local file path to full-resolution image
    var imageURL: URL
    
    /// Artistic style used
    var style: ArtStyle
    
    /// Creation timestamp
    var createdAt: Date
    
    /// Last modification timestamp
    var modifiedAt: Date
    
    /// Original prompt from first generation (before edits)
    var originalPrompt: String?
    
    /// History of voice-based edits
    var editHistory: [EditRecord]
    
    /// Cached thumbnail data for gallery
    var thumbnailData: Data?
    
    /// User favorite status
    var isFavorite: Bool
    
    /// User-defined tags for organization
    var tags: [String]
    
    /// Generation metadata (encoded)
    var metadataJSON: Data?
    
    /// Computed property for metadata
    var metadata: GenerationMetadata? {
        get {
            guard let data = metadataJSON else { return nil }
            return try? JSONDecoder().decode(GenerationMetadata.self, from: data)
        }
        set {
            metadataJSON = try? JSONEncoder().encode(newValue)
        }
    }
    
    init(
        id: UUID = UUID(),
        prompt: String,
        imageURL: URL,
        style: ArtStyle,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        originalPrompt: String? = nil,
        editHistory: [EditRecord] = [],
        thumbnailData: Data? = nil,
        isFavorite: Bool = false,
        tags: [String] = [],
        metadata: GenerationMetadata? = nil
    ) {
        self.id = id
        self.prompt = prompt
        self.imageURL = imageURL
        self.style = style
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.originalPrompt = originalPrompt ?? prompt
        self.editHistory = editHistory
        self.thumbnailData = thumbnailData
        self.isFavorite = isFavorite
        self.tags = tags
        self.metadataJSON = try? JSONEncoder().encode(metadata)
    }
}

/// Record of an edit made to artwork
struct EditRecord: Codable, Hashable, Sendable {
    /// When edit was made
    let timestamp: Date
    
    /// Voice command used
    let voiceCommand: String
    
    /// Previous version's image URL (for undo)
    let previousImageURL: URL?
    
    init(timestamp: Date = Date(), voiceCommand: String, previousImageURL: URL? = nil) {
        self.timestamp = timestamp
        self.voiceCommand = voiceCommand
        self.previousImageURL = previousImageURL
    }
}
