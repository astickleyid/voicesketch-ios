//
//  VoiceCommand.swift
//  VoiceSketch
//

import Foundation

struct VoiceCommand: Sendable {
    enum Intent: Sendable {
        case create(description: String, style: ArtStyle?)
        case edit(EditType)
        case delete
        case export
        case favorite
        case unknown
    }
    
    enum EditType: Sendable {
        case addElement(String)
        case removeElement(String)
        case changeColor(element: String?, color: String)
        case changeStyle(ArtStyle)
        case enhance(aspect: String)
    }
    
    let rawTranscript: String
    let intent: Intent
    let confidence: Float
    
    init(rawTranscript: String, intent: Intent, confidence: Float) {
        self.rawTranscript = rawTranscript
        self.intent = intent
        self.confidence = confidence
    }
}
