import Foundation
@testable import Tracker

actor MockExpenseRepository: ExpenseRepository {
    private var items: [Expense]

    init(items: [Expense] = []) {
        self.items = items
    }

    func seed(_ expenses: [Expense]) {
        items.append(contentsOf: expenses)
    }

    func add(_ expense: Expense) async throws {
        items.append(expense)
    }

    func all() async throws -> [Expense] {
        items
    }

    func expenses(in yearMonth: YearMonth, calendar: Calendar) async throws -> [Expense] {
        items.filter { yearMonth.contains(date: $0.date, calendar: calendar) }
    }
}

actor MockBudgetRepository: BudgetRepository {
    private var items: [UUID: Budget] = [:]

    func seed(_ budgets: [Budget]) {
        for budget in budgets {
            items[budget.id] = budget
        }
    }

    func budgets(for yearMonth: YearMonth) async throws -> [Budget] {
        items.values.filter { $0.yearMonth == yearMonth }
    }

    func setBudget(_ budget: Budget) async throws {
        items[budget.id] = budget
    }

    func remove(budgetId: UUID) async throws {
        items.removeValue(forKey: budgetId)
    }
}
