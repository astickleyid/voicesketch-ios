import SwiftUI

enum Theme {
    enum Colors {
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let primary = Color(.systemBlue)
        static let secondaryText = Color(.secondaryLabel)
    }
    
    enum Typography {
        static let headline = Font.headline
        static let body = Font.body
        static let caption = Font.caption
        static let callout = Font.callout
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
    }
    
    enum CornerRadius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
    }
}
