//
//  VoiceCommandParser.swift
//  VoiceSketch
//

import Foundation

/// Parses voice transcripts into structured commands
struct VoiceCommandParser {
    private let logger = AppLogger(category: "VoiceCommandParser")
    
    /// Parse transcript into voice command
    func parse(_ transcript: String) -> VoiceCommand {
        let normalized = transcript.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        logger.info("Parsing: \(transcript)")
        
        // Detect intent
        if isCreateCommand(normalized) {
            return parseCreateCommand(transcript, normalized: normalized)
        }
        
        if isEditCommand(normalized) {
            return parseEditCommand(transcript, normalized: normalized)
        }
        
        if isDeleteCommand(normalized) {
            return VoiceCommand(
                rawTranscript: transcript,
                intent: .delete,
                confidence: 0.9
            )
        }
        
        if isExportCommand(normalized) {
            return VoiceCommand(
                rawTranscript: transcript,
                intent: .export,
                confidence: 0.9
            )
        }
        
        if isFavoriteCommand(normalized) {
            return VoiceCommand(
                rawTranscript: transcript,
                intent: .favorite,
                confidence: 0.9
            )
        }
        
        // Default to create with lower confidence
        return VoiceCommand(
            rawTranscript: transcript,
            intent: .create(description: transcript, style: nil),
            confidence: 0.5
        )
    }
    
    // MARK: - Intent Detection
    
    private func isCreateCommand(_ text: String) -> Bool {
        let createKeywords = ["create", "draw", "make", "generate", "paint", "sketch", "design"]
        return createKeywords.contains { text.contains($0) }
    }
    
    private func isEditCommand(_ text: String) -> Bool {
        let editKeywords = ["change", "modify", "edit", "add", "remove", "make it"]
        return editKeywords.contains { text.contains($0) }
    }
    
    private func isDeleteCommand(_ text: String) -> Bool {
        text.contains("delete") || text.contains("remove this")
    }
    
    private func isExportCommand(_ text: String) -> Bool {
        text.contains("export") || text.contains("save") || text.contains("share")
    }
    
    private func isFavoriteCommand(_ text: String) -> Bool {
        text.contains("favorite") || text.contains("favourite") || text.contains("like this")
    }
    
    // MARK: - Create Command Parsing
    
    private func parseCreateCommand(_ original: String, normalized: String) -> VoiceCommand {
        // Extract style
        let style = extractStyle(from: normalized)
        
        // Extract description (remove command words and style)
        var description = original
        let removeWords = ["create", "draw", "make", "generate", "paint", "sketch", "design", "a", "an", "the"]
        
        for word in removeWords {
            description = description.replacingOccurrences(
                of: "\\b\(word)\\b",
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        if let style = style {
            description = description.replacingOccurrences(
                of: style.rawValue,
                with: "",
                options: .caseInsensitive
            )
        }
        
        description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return VoiceCommand(
            rawTranscript: original,
            intent: .create(description: description, style: style),
            confidence: 0.85
        )
    }
    
    // MARK: - Edit Command Parsing
    
    private func parseEditCommand(_ original: String, normalized: String) -> VoiceCommand {
        // Add element
        if normalized.contains("add") {
            let element = extractElement(from: original, after: "add")
            return VoiceCommand(
                rawTranscript: original,
                intent: .edit(.addElement(element)),
                confidence: 0.8
            )
        }
        
        // Remove element
        if normalized.contains("remove") || normalized.contains("delete") {
            let element = extractElement(from: original, after: ["remove", "delete"])
            return VoiceCommand(
                rawTranscript: original,
                intent: .edit(.removeElement(element)),
                confidence: 0.8
            )
        }
        
        // Change color
        if normalized.contains("color") || normalized.contains("make it") {
            let color = extractColor(from: normalized)
            return VoiceCommand(
                rawTranscript: original,
                intent: .edit(.changeColor(element: nil, color: color)),
                confidence: 0.75
            )
        }
        
        // Change style
        if let style = extractStyle(from: normalized) {
            return VoiceCommand(
                rawTranscript: original,
                intent: .edit(.changeStyle(style)),
                confidence: 0.8
            )
        }
        
        // Generic enhancement
        return VoiceCommand(
            rawTranscript: original,
            intent: .edit(.enhance(aspect: "overall")),
            confidence: 0.6
        )
    }
    
    // MARK: - Extraction Helpers
    
    private func extractStyle(from text: String) -> ArtStyle? {
        for style in ArtStyle.allCases {
            if text.contains(style.rawValue.lowercased()) {
                return style
            }
            
            // Check for partial matches
            let words = style.rawValue.lowercased().split(separator: " ")
            for word in words where word.count > 3 {
                if text.contains(String(word)) {
                    return style
                }
            }
        }
        return nil
    }
    
    private func extractElement(from text: String, after keywords: [String]) -> String {
        let normalized = text.lowercased()
        
        for keyword in keywords {
            if let range = normalized.range(of: keyword) {
                let afterKeyword = String(text[range.upperBound...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return afterKeyword.components(separatedBy: .whitespacesAndNewlines)
                    .prefix(3)
                    .joined(separator: " ")
            }
        }
        
        return text
    }
    
    private func extractElement(from text: String, after keyword: String) -> String {
        extractElement(from: text, after: [keyword])
    }
    
    private func extractColor(from text: String) -> String {
        let colors = ["red", "blue", "green", "yellow", "purple", "orange", "pink",
                      "black", "white", "gray", "grey", "brown", "cyan", "magenta"]
        
        for color in colors {
            if text.contains(color) {
                return color
            }
        }
        
        return "colorful"
    }
}
