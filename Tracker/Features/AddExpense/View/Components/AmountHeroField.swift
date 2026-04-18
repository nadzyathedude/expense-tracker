import SwiftUI

struct AmountHeroField: View {
    @Binding var amount: String
    let symbol: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.sm) {
            Text(symbol)
                .font(Theme.Typography.hero)
                .foregroundStyle(Theme.Palette.subtleText)

            TextField("0", text: $amount)
                .font(Theme.Typography.hero)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.leading)
                .textFieldStyle(.plain)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}
