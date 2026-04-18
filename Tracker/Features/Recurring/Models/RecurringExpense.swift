//
//  RecurringExpense.swift
//  Tracker
//

import Foundation

enum RecurrenceFrequency: String, CaseIterable, Identifiable, Codable {
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

struct RecurringExpense: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var amount: Decimal
    var currency: Currency
    var categoryKey: String
    var frequency: RecurrenceFrequency
    var nextDate: Date

    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        currency: Currency = .usd,
        categoryKey: String = "other",
        frequency: RecurrenceFrequency = .monthly,
        nextDate: Date
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currency = currency
        self.categoryKey = categoryKey
        self.frequency = frequency
        self.nextDate = nextDate
    }
}
