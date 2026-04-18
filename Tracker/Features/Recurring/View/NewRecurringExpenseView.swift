//
//  NewRecurringExpenseView.swift
//  Tracker
//

import SwiftUI

struct NewRecurringExpenseView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var currency: Currency = .usd
    @State private var frequency: RecurrenceFrequency = .monthly
    @State private var nextDate: Date = .now

    let onSave: (RecurringExpense) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Netflix, Spotify...", text: $title)
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                    Picker("Currency", selection: $currency) {
                        ForEach(Currency.all) { currency in
                            Text("\(currency.code) — \(currency.symbol)").tag(currency)
                        }
                    }
                }

                Section("Schedule") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(RecurrenceFrequency.allCases) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Next charge", selection: $nextDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Recurring")
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

    private var parsedAmount: Decimal? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else { return nil }
        return value
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && parsedAmount != nil
    }

    private func save() {
        guard let amount = parsedAmount else { return }
        let recurring = RecurringExpense(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amount,
            currency: currency,
            frequency: frequency,
            nextDate: nextDate
        )
        onSave(recurring)
        dismiss()
    }
}
