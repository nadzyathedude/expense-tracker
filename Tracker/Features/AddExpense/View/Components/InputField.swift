//
//  InputField.swift
//  Tracker
//

import SwiftUI

struct InputField<Trailing: View>: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.Palette.subtleText)
                .textCase(.uppercase)

            HStack(spacing: Theme.Spacing.s) {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .font(.body)
                    .textFieldStyle(.plain)

                trailing()
            }
            .padding(.horizontal, Theme.Spacing.m)
            .padding(.vertical, Theme.Spacing.m - 2)
            .background(Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.field, style: .continuous))
        }
    }
}

extension InputField where Trailing == EmptyView {
    init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.keyboard = keyboard
        self.trailing = { EmptyView() }
    }
}
