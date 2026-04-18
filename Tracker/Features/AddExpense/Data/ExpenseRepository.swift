import Foundation

protocol ExpenseRepository: Sendable {
    func add(_ expense: Expense) async throws
    func all() async throws -> [Expense]
    func expenses(in yearMonth: YearMonth, calendar: Calendar) async throws -> [Expense]
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

    func expenses(in yearMonth: YearMonth, calendar: Calendar = .current) async throws -> [Expense] {
        try await dataSource.fetch(in: yearMonth, calendar: calendar)
    }
}
