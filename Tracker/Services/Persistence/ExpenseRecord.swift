//
//  ExpenseRecord.swift
//  Tracker
//

import Foundation
import SwiftData

@Model
final class ExpenseRecord {
    var id: UUID = UUID()
    var title: String = ""
    var amount: Decimal = 0
    var currencyCode: String = "USD"
    var currencySymbol: String = "$"
    var currencyName: String = "US Dollar"
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        title: String = "",
        amount: Decimal = 0,
        currencyCode: String = "USD",
        currencySymbol: String = "$",
        currencyName: String = "US Dollar",
        createdAt: Date = Date()
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
