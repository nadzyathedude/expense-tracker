import SwiftUI

struct SuccessOverlay: View {
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white)
            Text("Expense added")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md - 4)
        .background(
            Capsule()
                .fill(Theme.Palette.success.opacity(0.95))
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
