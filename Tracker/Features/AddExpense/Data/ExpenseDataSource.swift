import Foundation

protocol ExpenseDataSource: Sendable {
    func save(_ expense: Expense) async throws
    func fetchAll() async throws -> [Expense]
}

actor InMemoryExpenseDataSource: ExpenseDataSource {
    private var storage: [Expense] = []

    func save(_ expense: Expense) async throws {
        storage.append(expense)
    }

    func fetchAll() async throws -> [Expense] {
        storage
    }
}
