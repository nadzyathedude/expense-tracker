//
//  ExpenseDataSource.swift
//  Tracker
//

import Foundation

protocol ExpenseDataSource {
    func save(_ expense: Expense) async throws
    func fetchAll() async throws -> [Expense]
}

actor InMemoryExpenseDataSource: ExpenseDataSource {
    private var storage: [Expense] = []

    func save(_ expense: Expense) async throws {
        storage.append(expense)
    }

    func fetchAll() async throws -> [Expense] {
        storage
    }
}
