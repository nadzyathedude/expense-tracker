import Foundation
import SwiftData

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let budgetRepository: BudgetRepository
    let setMonthlyBudgetUseCase: SetMonthlyBudgetUseCase
    let getMonthlyBudgetSummaryUseCase: GetMonthlyBudgetSummaryUseCase

    init(persistence: Persistence = .swiftData) {
        let (expenseDataSource, budgetDataSource) = Self.makeDataSources(for: persistence)
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

    enum Persistence {
        case swiftData
        case inMemory
    }

    private static func makeDataSources(
        for persistence: Persistence
    ) -> (ExpenseDataSource, BudgetDataSource) {
        switch persistence {
        case .swiftData:
            if let container = try? PersistenceStack.makeContainer() {
                return (
                    SwiftDataExpenseDataSource(modelContainer: container),
                    SwiftDataBudgetDataSource(modelContainer: container)
                )
            }
            return (InMemoryExpenseDataSource(), InMemoryBudgetDataSource())
        case .inMemory:
            return (InMemoryExpenseDataSource(), InMemoryBudgetDataSource())
        }
    }
}
