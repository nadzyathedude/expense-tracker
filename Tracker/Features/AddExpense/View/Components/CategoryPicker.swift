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
            HStack(spacing: Theme.Spacing.s) {
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
            .padding(.horizontal, Theme.Spacing.m)
            .padding(.vertical, Theme.Spacing.s + 4)
            .background(Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.field, style: .continuous))
        }
    }
}
