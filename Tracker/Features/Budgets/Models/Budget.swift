//
//  Budget.swift
//  Tracker
//

import Foundation

enum BudgetPeriod: String, CaseIterable, Identifiable, Codable {
    case weekly
    case monthly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
}

struct Budget: Identifiable, Hashable, Codable {
    let id: UUID
    var categoryKey: String
    var limit: Decimal
    var currency: Currency
    var period: BudgetPeriod

    init(
        id: UUID = UUID(),
        categoryKey: String,
        limit: Decimal,
        currency: Currency = .usd,
        period: BudgetPeriod = .monthly
    ) {
        self.id = id
        self.categoryKey = categoryKey
        self.limit = limit
        self.currency = currency
        self.period = period
    }
}
