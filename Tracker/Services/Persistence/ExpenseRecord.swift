//
//  ExpenseRecord.swift
//  Tracker
//

import Foundation
import SwiftData

@Model
final class ExpenseRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Decimal
    var currencyCode: String
    var currencySymbol: String
    var currencyName: String
    var createdAt: Date

    init(
        id: UUID,
        title: String,
        amount: Decimal,
        currencyCode: String,
        currencySymbol: String,
        currencyName: String,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currencyCode = currencyCode
        self.currencySymbol = currencySymbol
        self.currencyName = currencyName
        self.createdAt = createdAt
    }
}

extension ExpenseRecord {
    convenience init(expense: Expense) {
        self.init(
            id: expense.id,
            title: expense.title,
            amount: expense.amount,
            currencyCode: expense.currency.code,
            currencySymbol: expense.currency.symbol,
            currencyName: expense.currency.name,
            createdAt: expense.createdAt
        )
    }

    func toExpense() -> Expense {
        Expense(
            id: id,
            title: title,
            amount: amount,
            currency: Currency(code: currencyCode, symbol: currencySymbol, name: currencyName),
            createdAt: createdAt
        )
    }
}
