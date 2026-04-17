import Foundation
import SwiftData
import Testing
@testable import Tracker

@Suite("SwiftDataBudgetDataSource")
struct SwiftDataBudgetDataSourceTests {
    @Test("upsert persists and fetch returns by month")
    func upsertPersists() async throws {
        let dataSource = try makeDataSource()
        let april = YearMonth(year: 2026, month: 4)
        let budget = Budget(yearMonth: april, amount: 500, currency: .usd)

        try await dataSource.upsert(budget)
        let fetched = try await dataSource.fetch(yearMonth: april)

        #expect(fetched.count == 1)
        #expect(fetched.first?.amount == Decimal(500))
        #expect(fetched.first?.isOverall == true)
    }

    @Test("upsert collapses duplicates sharing (month, category, currency)")
    func upsertCollapsesDuplicates() async throws {
        let dataSource = try makeDataSource()
        let april = YearMonth(year: 2026, month: 4)

        try await dataSource.upsert(
            Budget(yearMonth: april, category: .food, amount: 100, currency: .usd)
        )
        try await dataSource.upsert(
            Budget(yearMonth: april, category: .food, amount: 250, currency: .usd)
        )

        let fetched = try await dataSource.fetch(yearMonth: april)
        #expect(fetched.count == 1)
        #expect(fetched.first?.amount == Decimal(250))
    }

    @Test("keeps separate budgets across different months")
    func keepsSeparateAcrossMonths() async throws {
        let dataSource = try makeDataSource()
        let april = YearMonth(year: 2026, month: 4)
        let may = YearMonth(year: 2026, month: 5)

        try await dataSource.upsert(Budget(yearMonth: april, amount: 100, currency: .usd))
        try await dataSource.upsert(Budget(yearMonth: may, amount: 200, currency: .usd))

        #expect(try await dataSource.fetch(yearMonth: april).count == 1)
        #expect(try await dataSource.fetch(yearMonth: may).count == 1)
    }

    @Test("keeps separate budgets across different currencies")
    func keepsSeparateAcrossCurrencies() async throws {
        let dataSource = try makeDataSource()
        let april = YearMonth(year: 2026, month: 4)

        try await dataSource.upsert(Budget(yearMonth: april, amount: 100, currency: .usd))
        try await dataSource.upsert(Budget(yearMonth: april, amount: 90, currency: .eur))

        let fetched = try await dataSource.fetch(yearMonth: april)
        #expect(fetched.count == 2)
    }

    @Test("delete removes only the targeted budget")
    func deleteRemovesTargeted() async throws {
        let dataSource = try makeDataSource()
        let april = YearMonth(year: 2026, month: 4)
        let food = Budget(yearMonth: april, category: .food, amount: 100, currency: .usd)
        let coffee = Budget(yearMonth: april, category: .coffee, amount: 40, currency: .usd)

        try await dataSource.upsert(food)
        try await dataSource.upsert(coffee)
        try await dataSource.delete(id: food.id)

        let fetched = try await dataSource.fetch(yearMonth: april)
        #expect(fetched.count == 1)
        #expect(fetched.first?.category == .coffee)
    }

    private func makeDataSource() throws -> SwiftDataBudgetDataSource {
        let schema = Schema([ExpensePersistent.self, BudgetPersistent.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return SwiftDataBudgetDataSource(modelContainer: container)
    }
}
