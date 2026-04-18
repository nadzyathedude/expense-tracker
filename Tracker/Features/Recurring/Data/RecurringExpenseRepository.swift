//
//  RecurringExpenseRepository.swift
//  Tracker
//

import Foundation

nonisolated protocol RecurringExpenseRepository: Sendable {
    func fetchAll() async throws -> [RecurringExpense]
    func add(_ recurring: RecurringExpense) async throws
    func update(_ recurring: RecurringExpense) async throws
    func delete(id: UUID) async throws
}

actor InMemoryRecurringExpenseRepository: RecurringExpenseRepository {
    private var storage: [UUID: RecurringExpense]

    init(initial: [RecurringExpense] = []) {
        self.storage = Dictionary(uniqueKeysWithValues: initial.map { ($0.id, $0) })
    }

    func fetchAll() async throws -> [RecurringExpense] {
        Array(storage.values).sorted { $0.nextDate < $1.nextDate }
    }

    func add(_ recurring: RecurringExpense) async throws {
        storage[recurring.id] = recurring
    }

    func update(_ recurring: RecurringExpense) async throws {
        storage[recurring.id] = recurring
    }

    func delete(id: UUID) async throws {
        storage.removeValue(forKey: id)
    }
}
