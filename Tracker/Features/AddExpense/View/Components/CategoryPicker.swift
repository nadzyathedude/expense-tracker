import SwiftUI

struct CategoryPicker: View {
    @Binding var selection: ExpenseCategory?
    let categories: [ExpenseCategory]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                chip(label: "None", icon: "slash.circle", isSelected: selection == nil) {
                    selection = nil
                }
                .accessibilityIdentifier("CategoryChip_none")

                ForEach(categories) { category in
                    chip(
                        label: category.name,
                        icon: category.icon,
                        isSelected: selection == category
                    ) {
                        selection = category
                    }
                    .accessibilityIdentifier("CategoryChip_\(category.id)")
                }
            }
            .padding(.horizontal, 1)
        }
    }

    @ViewBuilder
    private func chip(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(label)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isSelected ? Theme.Palette.accent : Theme.Palette.surface)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}
