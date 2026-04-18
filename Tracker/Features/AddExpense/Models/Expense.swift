//
//  Expense.swift
//  Tracker
//

import Foundation

struct Expense: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let amount: Decimal
    let currency: Currency
    let category: Category
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        currency: Currency,
        category: Category = .other,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currency = currency
        self.category = category
        self.createdAt = createdAt
    }
}
