import Foundation
import SwiftData
import Testing
@testable import Tracker

@Suite("SwiftDataExpenseDataSource")
struct SwiftDataExpenseDataSourceTests {
    @Test("save persists an expense and fetchAll returns it")
    func savePersistsAndFetchAll() async throws {
        let dataSource = try makeDataSource()
        let expense = Expense(
            title: "Coffee",
            amount: 4.5,
            currency: .usd,
            category: .coffee,
            date: TestCalendar.date(year: 2026, month: 4, day: 5)
        )

        try await dataSource.save(expense)
        let all = try await dataSource.fetchAll()

        #expect(all.count == 1)
        let saved = try #require(all.first)
        #expect(saved.id == expense.id)
        #expect(saved.title == "Coffee")
        #expect(saved.amount == Decimal(string: "4.5"))
        #expect(saved.currency == .usd)
        #expect(saved.category == .coffee)
    }

    @Test("save with same id upserts instead of duplicating")
    func saveWithSameIdUpserts() async throws {
        let dataSource = try makeDataSource()
        let id = UUID()
        let first = Expense(
            id: id, title: "Coffee", amount: 4,
            currency: .usd, category: .coffee,
            date: TestCalendar.date(year: 2026, month: 4, day: 5)
        )
        let updated = Expense(
            id: id, title: "Latte", amount: 6,
            currency: .usd, category: .coffee,
            date: TestCalendar.date(year: 2026, month: 4, day: 5)
        )

        try await dataSource.save(first)
        try await dataSource.save(updated)

        let all = try await dataSource.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.title == "Latte")
        #expect(all.first?.amount == Decimal(6))
    }

    @Test("fetch(in:) filters to the target month")
    func fetchInMonthFilters() async throws {
        let dataSource = try makeDataSource()
        let april = YearMonth(year: 2026, month: 4)
        let calendar = TestCalendar.gregorianUTC()

        try await dataSource.save(Expense(
            title: "In", amount: 10, currency: .usd,
            date: TestCalendar.date(year: 2026, month: 4, day: 1)
        ))
        try await dataSource.save(Expense(
            title: "Also in", amount: 11, currency: .usd,
            date: TestCalendar.date(year: 2026, month: 4, day: 30)
        ))
        try await dataSource.save(Expense(
            title: "Prev month", amount: 99, currency: .usd,
            date: TestCalendar.date(year: 2026, month: 3, day: 31)
        ))
        try await dataSource.save(Expense(
            title: "Next month", amount: 99, currency: .usd,
            date: TestCalendar.date(year: 2026, month: 5, day: 1)
        ))

        let found = try await dataSource.fetch(in: april, calendar: calendar)
        #expect(found.count == 2)
        #expect(found.allSatisfy { $0.amount == Decimal(10) || $0.amount == Decimal(11) })
    }

    private func makeDataSource() throws -> SwiftDataExpenseDataSource {
        let schema = Schema([ExpensePersistent.self, BudgetPersistent.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return SwiftDataExpenseDataSource(modelContainer: container)
    }
}
