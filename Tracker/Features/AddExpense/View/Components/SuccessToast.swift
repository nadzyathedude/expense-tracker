//
//  SuccessToast.swift
//  Tracker
//

import SwiftUI

struct SuccessToast: View {
    let message: String

    var body: some View {
        HStack(spacing: Theme.Spacing.s) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, Theme.Spacing.l)
        .padding(.vertical, Theme.Spacing.m - 4)
        .background(
            Capsule()
                .fill(Color.green.opacity(0.95))
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
