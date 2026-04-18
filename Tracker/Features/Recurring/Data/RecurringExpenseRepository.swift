//
//  RecurringExpenseRepository.swift
//  Tracker
//

import Foundation

nonisolated protocol RecurringExpenseRepository: Sendable {
    func fetchAll() async throws -> [RecurringExpense]
}

actor InMemoryRecurringExpenseRepository: RecurringExpenseRepository {
    private var storage: [RecurringExpense]

    init(initial: [RecurringExpense] = []) {
        self.storage = initial
    }

    func fetchAll() async throws -> [RecurringExpense] {
        storage
    }
}
