//
//  HapticManager.swift
//  VoiceSketch
//

import UIKit

@MainActor
final class HapticManager {
    static let shared = HapticManager()
    
    private let impact = UIImpactFeedbackGenerator(style: .medium)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    
    private init() {}
    
    func prepare() {
        impact.prepare()
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func success() {
        notification.notificationOccurred(.success)
    }
    
    func error() {
        notification.notificationOccurred(.error)
    }
    
    func warning() {
        notification.notificationOccurred(.warning)
    }
    
    func playSelection() {
        selection.selectionChanged()
    }
}
