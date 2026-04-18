//
//  CategoryPicker.swift
//  Tracker
//

import SwiftUI

struct CategoryPicker: View {
    @Binding var selection: Category
    let categories: [Category]

    var body: some View {
        Menu {
            ForEach(categories) { category in
                Button {
                    selection = category
                } label: {
                    Label(category.name, systemImage: category.iconName)
                }
            }
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: selection.iconName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(selection.color)
                Text(selection.name)
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm + 4)
            .background(Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.field, style: .continuous))
        }
    }
}
