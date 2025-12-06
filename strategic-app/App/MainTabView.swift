//
//  MainTabView.swift
//  VoiceSketch
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CreationView()
                .tabItem {
                    Label("Create", systemImage: "mic.circle.fill")
                }
                .tag(0)
            
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.stack")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .accentColor(Theme.Colors.primary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Artwork.self, inMemory: true)
}
