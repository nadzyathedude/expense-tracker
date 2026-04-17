import SwiftUI

struct CategoryBudgetRow: View {
    let breakdown: CategoryBudgetBreakdown
    let currency: Currency
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            content
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("CategoryRow_\(breakdown.category.id)")
    }

    private var content: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: breakdown.category.icon)
                .font(.title3)
                .foregroundStyle(Theme.Palette.accent)
                .frame(width: 32, height: 32)
                .background(Theme.Palette.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Text(breakdown.category.name)
                        .font(.body.weight(.semibold))
                    Spacer()
                    spentLabel
                }
                if let progress = breakdown.progress {
                    BudgetProgressBar(progress: progress, isOver: breakdown.isOverBudget)
                }
                budgetLine
            }
        }
        .padding(.vertical, Theme.Spacing.sm)
    }

    private var spentLabel: some View {
        Text(MoneyFormatter.string(amount: breakdown.spent, currency: currency))
            .font(.body.weight(.medium))
            .foregroundStyle(breakdown.isOverBudget ? Color.red : .primary)
    }

    private var budgetLine: some View {
        HStack {
            if let budget = breakdown.budget {
                Text("of \(MoneyFormatter.string(amount: budget, currency: currency))")
                    .font(.caption)
                    .foregroundStyle(Theme.Palette.subtleText)
            } else {
                Text("Tap to set a budget")
                    .font(.caption)
                    .foregroundStyle(Theme.Palette.subtleText)
            }
            Spacer()
        }
    }
}
