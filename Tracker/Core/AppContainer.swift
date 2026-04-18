import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let budgetRepository: BudgetRepository
    let setMonthlyBudgetUseCase: SetMonthlyBudgetUseCase
    let getMonthlyBudgetSummaryUseCase: GetMonthlyBudgetSummaryUseCase

    init() {
        let expenseDataSource = InMemoryExpenseDataSource()
        let budgetDataSource = InMemoryBudgetDataSource()
        self.expenseRepository = DefaultExpenseRepository(dataSource: expenseDataSource)
        self.budgetRepository = DefaultBudgetRepository(dataSource: budgetDataSource)
        self.setMonthlyBudgetUseCase = DefaultSetMonthlyBudgetUseCase(repository: budgetRepository)
        self.getMonthlyBudgetSummaryUseCase = DefaultGetMonthlyBudgetSummaryUseCase(
            expenseRepository: expenseRepository,
            budgetRepository: budgetRepository
        )
    }

    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(repository: expenseRepository)
    }

    func makeBudgetPlanningViewModel() -> BudgetPlanningViewModel {
        BudgetPlanningViewModel(
            summaryUseCase: getMonthlyBudgetSummaryUseCase,
            setBudgetUseCase: setMonthlyBudgetUseCase
        )
    }
}
