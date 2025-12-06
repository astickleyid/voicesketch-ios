//
//  Theme.swift
//  VoiceSketch
//

import SwiftUI

enum Theme {
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.purple
        static let accent = Color.pink
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
        
        static let background = Color(uiColor: .systemBackground)
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
        
        static let text = Color.primary
        static let secondaryText = Color.secondary
    }
    
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    enum Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    enum Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
    }
}
