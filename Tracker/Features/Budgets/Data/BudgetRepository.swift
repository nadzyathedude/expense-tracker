//
//  BudgetRepository.swift
//  Tracker
//

import Foundation

protocol BudgetRepository {
    func fetchAll() async throws -> [Budget]
    func add(_ budget: Budget) async throws
    func update(_ budget: Budget) async throws
    func delete(id: UUID) async throws
}

actor InMemoryBudgetRepository: BudgetRepository {
    private var storage: [UUID: Budget] = [:]

    func fetchAll() async throws -> [Budget] {
        Array(storage.values).sorted { $0.categoryKey < $1.categoryKey }
    }

    func add(_ budget: Budget) async throws {
        storage[budget.id] = budget
    }

    func update(_ budget: Budget) async throws {
        storage[budget.id] = budget
    }

    func delete(id: UUID) async throws {
        storage.removeValue(forKey: id)
    }
}
