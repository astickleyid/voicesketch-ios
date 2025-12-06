//
//  VoiceSketchApp.swift
//  VoiceSketch
//

import SwiftUI
import SwiftData

@main
struct VoiceSketchApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Artwork.self)
    }
}
