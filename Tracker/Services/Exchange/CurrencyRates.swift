//
//  CurrencyRates.swift
//  Tracker
//

import Foundation

nonisolated struct CurrencyRates: Codable, Equatable, Sendable {
    let base: String
    let fetchedAt: Date
    let rates: [String: Decimal]
}

nonisolated struct ExchangeRatesResponse: Decodable, Sendable {
    let base: String
    let rates: [String: Decimal]
}
