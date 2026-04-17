import Foundation

protocol BudgetDataSource: Sendable {
    func fetch(yearMonth: YearMonth) async throws -> [Budget]
    func upsert(_ budget: Budget) async throws
    func delete(id: UUID) async throws
}

actor InMemoryBudgetDataSource: BudgetDataSource {
    private var storage: [UUID: Budget] = [:]

    func fetch(yearMonth: YearMonth) async throws -> [Budget] {
        storage.values.filter { $0.yearMonth == yearMonth }
    }

    func upsert(_ budget: Budget) async throws {
        if let existing = storage.values.first(where: { sameKey($0, budget) }),
           existing.id != budget.id {
            storage.removeValue(forKey: existing.id)
        }
        storage[budget.id] = budget
    }

    func delete(id: UUID) async throws {
        storage.removeValue(forKey: id)
    }

    private func sameKey(_ lhs: Budget, _ rhs: Budget) -> Bool {
        lhs.yearMonth == rhs.yearMonth
            && lhs.category == rhs.category
            && lhs.currency == rhs.currency
    }
}
