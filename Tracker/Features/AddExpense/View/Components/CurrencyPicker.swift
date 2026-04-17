//
//  CurrencyPicker.swift
//  Tracker
//

import SwiftUI

struct CurrencyPicker: View {
    @Binding var selection: Currency
    let currencies: [Currency]

    var body: some View {
        Menu {
            ForEach(currencies) { currency in
                Button {
                    selection = currency
                } label: {
                    HStack {
                        Text("\(currency.symbol)  \(currency.code)")
                        Spacer()
                        Text(currency.name)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } label: {
            HStack(spacing: Theme.Spacing.s) {
                Text(selection.symbol)
                    .font(.headline)
                Text(selection.code)
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
