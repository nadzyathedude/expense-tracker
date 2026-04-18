import SwiftUI

struct BudgetSummaryCard: View {
    let summary: BudgetSummary

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("THIS MONTH")
                    .font(Theme.Typography.label)
                    .foregroundStyle(Theme.Palette.subtleText)
                Spacer()
                Text(summary.yearMonth.displayString())
                    .font(.subheadline.weight(.semibold))
            }

            Text(MoneyFormatter.string(amount: summary.totalSpent, currency: summary.currency))
                .font(Theme.Typography.hero)
                .foregroundStyle(summary.isOverBudget ? Color.red : .primary)
                .accessibilityIdentifier("TotalSpentLabel")

            if let overallBudget = summary.overallBudget {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack {
                        Text("of \(MoneyFormatter.string(amount: overallBudget, currency: summary.currency))")
                            .font(.subheadline)
                            .foregroundStyle(Theme.Palette.subtleText)
                        Spacer()
                        remainingLabel(budget: overallBudget)
                    }
                    if let progress = summary.progress {
                        BudgetProgressBar(progress: progress, isOver: summary.isOverBudget)
                    }
                }
            } else {
                Text("No overall budget set")
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.subtleText)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
        .accessibilityIdentifier("BudgetSummaryCard")
    }

    private func remainingLabel(budget: Decimal) -> some View {
        let remaining = budget - summary.totalSpent
        let text = remaining >= 0
            ? "\(MoneyFormatter.string(amount: remaining, currency: summary.currency)) left"
            : "Over by \(MoneyFormatter.string(amount: -remaining, currency: summary.currency))"
        return Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(remaining >= 0 ? Theme.Palette.success : Color.red)
    }
}
