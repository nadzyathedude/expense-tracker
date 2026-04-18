import SwiftUI

struct SetBudgetSheet: View {
    let title: String
    let currency: Currency
    let existingAmount: Decimal?
    let onSave: (Decimal) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var amountText: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("Set a monthly cap in \(currency.code)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.subtleText)

                HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.sm) {
                    Text(currency.symbol)
                        .font(Theme.Typography.hero)
                        .foregroundStyle(Theme.Palette.subtleText)
                    TextField("0", text: $amountText)
                        .font(Theme.Typography.hero)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .focused($focused)
                        .accessibilityIdentifier("SetBudgetAmountField")
                }

                Spacer(minLength: 0)

                PrimaryButton(
                    title: "Save budget",
                    isLoading: false,
                    isEnabled: parsedAmount != nil
                ) {
                    if let amount = parsedAmount {
                        onSave(amount)
                        dismiss()
                    }
                }
                .accessibilityIdentifier("SaveBudgetButton")
            }
            .padding(Theme.Spacing.lg)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("CancelBudgetButton")
                }
            }
            .task {
                if let existingAmount {
                    amountText = formatted(existingAmount)
                }
                focused = true
            }
        }
    }

    private var parsedAmount: Decimal? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else {
            return nil
        }
        return value
    }

    private func formatted(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? ""
    }
}
