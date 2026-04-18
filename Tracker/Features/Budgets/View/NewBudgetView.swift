//
//  NewBudgetView.swift
//  Tracker
//

import SwiftUI

struct NewBudgetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var categoryKey: String = "food"
    @State private var amountText: String = ""
    @State private var currency: Currency = .usd
    @State private var period: BudgetPeriod = .monthly

    let onSave: (Budget) -> Void

    private let suggestedCategories = [
        "food", "transport", "entertainment", "shopping",
        "bills", "health", "travel", "other"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $categoryKey) {
                        ForEach(suggestedCategories, id: \.self) { key in
                            Text(key.capitalized).tag(key)
                        }
                    }
                }

                Section("Limit") {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                    Picker("Currency", selection: $currency) {
                        ForEach(Currency.all) { currency in
                            Text("\(currency.code) — \(currency.symbol)").tag(currency)
                        }
                    }
                }

                Section("Period") {
                    Picker("Period", selection: $period) {
                        ForEach(BudgetPeriod.allCases) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private var parsedLimit: Decimal? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else { return nil }
        return value
    }

    private var isValid: Bool {
        parsedLimit != nil && !categoryKey.isEmpty
    }

    private func save() {
        guard let limit = parsedLimit else { return }
        let budget = Budget(
            categoryKey: categoryKey,
            limit: limit,
            currency: currency,
            period: period
        )
        onSave(budget)
        dismiss()
    }
}
