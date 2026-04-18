import SwiftUI

enum Theme {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let field: CGFloat = 14
        static let button: CGFloat = 16
        static let chip: CGFloat = 20
    }

    enum Palette {
        static let accent = Color(red: 0.35, green: 0.45, blue: 0.95)
        static let success = Color(red: 0.22, green: 0.74, blue: 0.42)
        static let surface = Color(.secondarySystemBackground)
        static let background = Color(.systemBackground)
        static let subtleText = Color.secondary
    }

    enum Typography {
        static let hero: Font = .system(size: 56, weight: .semibold, design: .rounded)
        static let title: Font = .system(size: 28, weight: .bold, design: .default)
        static let label: Font = .system(size: 13, weight: .semibold, design: .default)
        static let body: Font = .system(size: 16, weight: .regular, design: .default)
    }
}
