import SwiftUI

struct CurrencyChip: View {
    @Binding var selection: Currency
    let currencies: [Currency]

    var body: some View {
        Menu {
            ForEach(currencies) { currency in
                Button {
                    selection = currency
                } label: {
                    Text("\(currency.symbol)  \(currency.code)  —  \(currency.name)")
                }
            }
        } label: {
            HStack(spacing: Theme.Spacing.xs) {
                Text(selection.code)
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Theme.Palette.surface)
            .clipShape(Capsule())
        }
    }
}
