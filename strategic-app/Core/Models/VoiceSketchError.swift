//
//  VoiceSketchError.swift
//  VoiceSketch
//

import Foundation

enum VoiceSketchError: LocalizedError {
    case voicePermissionDenied
    case voiceRecognitionFailed
    case apiError(underlying: Error)
    case networkTimeout
    case quotaExceeded
    case invalidPrompt
    case imageProcessingFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .voicePermissionDenied:
            return "Microphone access is required to create art with your voice."
        case .voiceRecognitionFailed:
            return "Unable to recognize speech. Please try again."
        case .apiError:
            return "Unable to generate image. Please try again."
        case .networkTimeout:
            return "Request timed out. Check your connection."
        case .quotaExceeded:
            return "You've reached your monthly limit. Upgrade to Pro for unlimited generations."
        case .invalidPrompt:
            return "Please provide a valid description."
        case .imageProcessingFailed:
            return "Failed to process image."
        case .saveFailed:
            return "Failed to save artwork."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .voicePermissionDenied:
            return "Enable microphone access in Settings"
        case .networkTimeout:
            return "Check your internet connection and try again"
        case .quotaExceeded:
            return "Upgrade to Pro"
        default:
            return "Try again"
        }
    }
}
