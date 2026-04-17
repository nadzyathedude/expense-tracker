//
//  Theme.swift
//  Tracker
//

import SwiftUI

enum Theme {
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let field: CGFloat = 14
        static let button: CGFloat = 16
        static let card: CGFloat = 20
    }

    enum Palette {
        static let accent = Color(red: 0.35, green: 0.45, blue: 0.95)
        static let surface = Color(.secondarySystemBackground)
        static let background = Color(.systemBackground)
        static let subtleText = Color.secondary
    }
}
