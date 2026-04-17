//
//  ExpenseRepository.swift
//  Tracker
//

import Foundation

protocol ExpenseRepository {
    func add(_ expense: Expense) async throws
    func all() async throws -> [Expense]
}

final class DefaultExpenseRepository: ExpenseRepository {
    private let dataSource: ExpenseDataSource

    init(dataSource: ExpenseDataSource) {
        self.dataSource = dataSource
    }

    func add(_ expense: Expense) async throws {
        try await dataSource.save(expense)
    }

    func all() async throws -> [Expense] {
        try await dataSource.fetchAll()
    }
}
