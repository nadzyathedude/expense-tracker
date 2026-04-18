//
//  ComingSoonView.swift
//  Tracker
//

import SwiftUI

struct ComingSoonView: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(Theme.Palette.subtleText)
            Text(title)
                .font(.title3.weight(.semibold))
            Text("Coming soon")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
