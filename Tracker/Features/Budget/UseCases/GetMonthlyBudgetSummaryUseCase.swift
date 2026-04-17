import Foundation

protocol GetMonthlyBudgetSummaryUseCase: Sendable {
    func execute(
        yearMonth: YearMonth,
        currency: Currency,
        calendar: Calendar
    ) async throws -> BudgetSummary
}

final class DefaultGetMonthlyBudgetSummaryUseCase: GetMonthlyBudgetSummaryUseCase {
    private let expenseRepository: ExpenseRepository
    private let budgetRepository: BudgetRepository

    init(
        expenseRepository: ExpenseRepository,
        budgetRepository: BudgetRepository
    ) {
        self.expenseRepository = expenseRepository
        self.budgetRepository = budgetRepository
    }

    func execute(
        yearMonth: YearMonth,
        currency: Currency,
        calendar: Calendar = .current
    ) async throws -> BudgetSummary {
        async let expensesTask = expenseRepository.expenses(in: yearMonth, calendar: calendar)
        async let budgetsTask = budgetRepository.budgets(for: yearMonth)
        let expenses = try await expensesTask
        let budgets = try await budgetsTask

        let matchingExpenses = expenses.filter { $0.currency == currency }
        let matchingBudgets = budgets.filter { $0.currency == currency }

        let overall = matchingBudgets.first { $0.isOverall }?.amount
        let totalSpent = matchingExpenses.reduce(Decimal(0)) { $0 + $1.amount }

        let breakdowns = ExpenseCategory.all.map { category in
            let spent = matchingExpenses
                .filter { $0.category == category }
                .reduce(Decimal(0)) { $0 + $1.amount }
            let budget = matchingBudgets.first { $0.category == category }?.amount
            return CategoryBudgetBreakdown(category: category, budget: budget, spent: spent)
        }

        return BudgetSummary(
            yearMonth: yearMonth,
            currency: currency,
            overallBudget: overall,
            totalSpent: totalSpent,
            categoryBreakdowns: breakdowns
        )
    }
}
