//
//  BaseCurrencyStore.swift
//  Tracker
//

import Foundation

nonisolated protocol BaseCurrencyStore: Sendable {
    func load() -> Currency
    func save(_ currency: Currency)
}

nonisolated final class UserDefaultsBaseCurrencyStore: BaseCurrencyStore {
    private let defaults: UserDefaults
    private let key = "settings.baseCurrency"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> Currency {
        guard let code = defaults.string(forKey: key),
              let currency = Currency.all.first(where: { $0.code == code }) else {
            return .usd
        }
        return currency
    }

    func save(_ currency: Currency) {
        defaults.set(currency.code, forKey: key)
    }
}
