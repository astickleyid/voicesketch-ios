//
//  ArtStyle.swift
//  VoiceSketch
//
//  Created on 2025-12-04
//

import SwiftUI

/// Represents different artistic styles available for AI generation
enum ArtStyle: String, Codable, CaseIterable, Identifiable {
    case photorealistic = "Photorealistic"
    case cartoon = "Cartoon"
    case anime = "Anime"
    case watercolor = "Watercolor"
    case oilPainting = "Oil Painting"
    case sketch = "Pencil Sketch"
    case digitalArt = "Digital Art"
    case abstract = "Abstract"
    case pixelArt = "Pixel Art"
    case impressionist = "Impressionist"
    case cyberpunk = "Cyberpunk"
    case fantasy = "Fantasy Art"
    
    var id: String { rawValue }
    
    /// Prompt modifier to append to user's description
    var promptSuffix: String {
        switch self {
        case .photorealistic:
            return "photorealistic, highly detailed, 8k resolution, professional photography"
        case .cartoon:
            return "cartoon style, vibrant colors, clean lines, animated"
        case .anime:
            return "anime style, manga art, Japanese animation aesthetic"
        case .watercolor:
            return "watercolor painting, soft edges, artistic, painted"
        case .oilPainting:
            return "oil painting, textured brushstrokes, classical art style"
        case .sketch:
            return "pencil sketch, hand-drawn, artistic line work, monochrome"
        case .digitalArt:
            return "digital art, concept art, modern illustration"
        case .abstract:
            return "abstract art, non-representational, artistic expression"
        case .pixelArt:
            return "pixel art, retro gaming aesthetic, 16-bit style"
        case .impressionist:
            return "impressionist painting, loose brushwork, light and color focus"
        case .cyberpunk:
            return "cyberpunk style, neon lights, futuristic, sci-fi aesthetic"
        case .fantasy:
            return "fantasy art, magical, epic, dramatic lighting"
        }
    }
    
    /// Icon to display in style picker
    var icon: String {
        switch self {
        case .photorealistic: return "camera.fill"
        case .cartoon: return "face.smiling"
        case .anime: return "star.circle.fill"
        case .watercolor: return "paintbrush.fill"
        case .oilPainting: return "paintpalette.fill"
        case .sketch: return "pencil"
        case .digitalArt: return "ipad.and.arrow.forward"
        case .abstract: return "waveform"
        case .pixelArt: return "square.grid.3x3.fill"
        case .impressionist: return "sparkles"
        case .cyberpunk: return "bolt.fill"
        case .fantasy: return "sparkle.magnifyingglass"
        }
    }
    
    /// Accent color for style card
    var accentColor: Color {
        switch self {
        case .photorealistic: return .blue
        case .cartoon: return .orange
        case .anime: return .pink
        case .watercolor: return .cyan
        case .oilPainting: return .brown
        case .sketch: return .gray
        case .digitalArt: return .purple
        case .abstract: return .indigo
        case .pixelArt: return .green
        case .impressionist: return .yellow
        case .cyberpunk: return .pink
        case .fantasy: return .purple
        }
    }
    
    /// Short description of the style
    var description: String {
        switch self {
        case .photorealistic: return "Ultra-realistic images"
        case .cartoon: return "Playful and vibrant"
        case .anime: return "Japanese animation style"
        case .watercolor: return "Soft, painted look"
        case .oilPainting: return "Classical art style"
        case .sketch: return "Hand-drawn appearance"
        case .digitalArt: return "Modern illustration"
        case .abstract: return "Non-representational art"
        case .pixelArt: return "Retro gaming aesthetic"
        case .impressionist: return "Light and color focus"
        case .cyberpunk: return "Futuristic neon aesthetic"
        case .fantasy: return "Magical and epic"
        }
    }
}
