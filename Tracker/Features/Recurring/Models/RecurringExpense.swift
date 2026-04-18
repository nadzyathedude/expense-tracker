//
//  RecurringExpense.swift
//  Tracker
//

import Foundation

nonisolated enum RecurrenceFrequency: String, CaseIterable, Identifiable, Codable, Sendable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    func advancing(from date: Date, calendar: Calendar = .current) -> Date {
        switch self {
        case .weekly: return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly: return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .yearly: return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
}

nonisolated struct RecurringExpense: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var title: String
    var amount: Decimal
    var currency: Currency
    var frequency: RecurrenceFrequency
    var nextDate: Date

    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        currency: Currency = .usd,
        frequency: RecurrenceFrequency = .monthly,
        nextDate: Date
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currency = currency
        self.frequency = frequency
        self.nextDate = nextDate
    }
}
