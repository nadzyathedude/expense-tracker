import Foundation

enum SetBudgetError: Error, Equatable {
    case nonPositiveAmount
}

protocol SetMonthlyBudgetUseCase: Sendable {
    func execute(
        yearMonth: YearMonth,
        category: ExpenseCategory?,
        amount: Decimal,
        currency: Currency
    ) async throws -> Budget
}

final class DefaultSetMonthlyBudgetUseCase: SetMonthlyBudgetUseCase {
    private let repository: BudgetRepository

    init(repository: BudgetRepository) {
        self.repository = repository
    }

    func execute(
        yearMonth: YearMonth,
        category: ExpenseCategory?,
        amount: Decimal,
        currency: Currency
    ) async throws -> Budget {
        guard amount > 0 else {
            throw SetBudgetError.nonPositiveAmount
        }
        let budget = Budget(
            yearMonth: yearMonth,
            category: category,
            amount: amount,
            currency: currency
        )
        try await repository.setBudget(budget)
        return budget
    }
}
