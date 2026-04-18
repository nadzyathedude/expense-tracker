//
//  ConvertCurrencyUseCase.swift
//  Tracker
//

import Foundation

nonisolated enum CurrencyConversionError: Error {
    case missingRate(from: String, to: String)
}

nonisolated struct ConvertCurrencyUseCase: Sendable {
    let repository: CurrencyRateRepository

    func execute(amount: Decimal, from: String, to: String) async throws -> Decimal {
        let source = from.uppercased()
        let target = to.uppercased()
        if source == target { return amount }

        let rates = try await repository.rates(base: source)
        guard let rate = rates.rates[target] else {
            throw CurrencyConversionError.missingRate(from: source, to: target)
        }
        return amount * rate
    }
}
