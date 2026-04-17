import Foundation
import Testing
@testable import Tracker

@Suite("DefaultBudgetRepository (integration with InMemory data source)")
struct BudgetRepositoryTests {
    @Test("upsert replaces existing budget with same key")
    func upsertReplacesSameKey() async throws {
        let dataSource = InMemoryBudgetDataSource()
        let repo = DefaultBudgetRepository(dataSource: dataSource)
        let april = YearMonth(year: 2026, month: 4)

        try await repo.setBudget(
            Budget(yearMonth: april, category: .food, amount: 100, currency: .usd)
        )
        try await repo.setBudget(
            Budget(yearMonth: april, category: .food, amount: 250, currency: .usd)
        )

        let budgets = try await repo.budgets(for: april)
        #expect(budgets.count == 1)
        #expect(budgets.first?.amount == Decimal(250))
    }

    @Test("keeps independent budgets across months")
    func keepsIndependentPerMonth() async throws {
        let dataSource = InMemoryBudgetDataSource()
        let repo = DefaultBudgetRepository(dataSource: dataSource)
        let april = YearMonth(year: 2026, month: 4)
        let may = YearMonth(year: 2026, month: 5)

        try await repo.setBudget(
            Budget(yearMonth: april, amount: 100, currency: .usd)
        )
        try await repo.setBudget(
            Budget(yearMonth: may, amount: 200, currency: .usd)
        )

        #expect(try await repo.budgets(for: april).count == 1)
        #expect(try await repo.budgets(for: may).count == 1)
    }

    @Test("remove deletes only the targeted budget")
    func removeDeletesTargeted() async throws {
        let dataSource = InMemoryBudgetDataSource()
        let repo = DefaultBudgetRepository(dataSource: dataSource)
        let april = YearMonth(year: 2026, month: 4)

        let food = Budget(yearMonth: april, category: .food, amount: 100, currency: .usd)
        let coffee = Budget(yearMonth: april, category: .coffee, amount: 40, currency: .usd)
        try await repo.setBudget(food)
        try await repo.setBudget(coffee)

        try await repo.remove(budgetId: food.id)
        let remaining = try await repo.budgets(for: april)
        #expect(remaining.count == 1)
        #expect(remaining.first?.category == .coffee)
    }
}
