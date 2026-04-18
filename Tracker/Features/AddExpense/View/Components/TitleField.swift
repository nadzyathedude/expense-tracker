import SwiftUI

struct TitleField: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("WHAT FOR?")
                .font(Theme.Typography.label)
                .foregroundStyle(Theme.Palette.subtleText)

            TextField("Groceries, Taxi, Coffee…", text: $text)
                .font(Theme.Typography.body)
                .textFieldStyle(.plain)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.md - 2)
                .background(Theme.Palette.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.field, style: .continuous))
        }
    }
}
