//
//  ExpenseRow.swift
//  Tracker
//

import SwiftUI

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(expense.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                Text(expense.createdAt, format: .dateTime.day().month().year().hour().minute())
                    .font(.footnote)
                    .foregroundStyle(Theme.Palette.subtleText)
            }
            Spacer(minLength: Theme.Spacing.md)
            Text(Self.formattedAmount(expense.amount, currency: expense.currency))
                .font(.headline.monospacedDigit())
                .foregroundStyle(.primary)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    private static func formattedAmount(_ amount: Decimal, currency: Currency) -> String {
        var formatter: Decimal.FormatStyle.Currency {
            .currency(code: currency.code).locale(.current)
        }
        return amount.formatted(formatter)
    }
}
