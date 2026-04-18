import Foundation

protocol BudgetRepository: Sendable {
    func budgets(for yearMonth: YearMonth) async throws -> [Budget]
    func setBudget(_ budget: Budget) async throws
    func remove(budgetId: UUID) async throws
}

final class DefaultBudgetRepository: BudgetRepository {
    private let dataSource: BudgetDataSource

    init(dataSource: BudgetDataSource) {
        self.dataSource = dataSource
    }

    func budgets(for yearMonth: YearMonth) async throws -> [Budget] {
        try await dataSource.fetch(yearMonth: yearMonth)
    }

    func setBudget(_ budget: Budget) async throws {
        try await dataSource.upsert(budget)
    }

    func remove(budgetId: UUID) async throws {
        try await dataSource.delete(id: budgetId)
    }
}
