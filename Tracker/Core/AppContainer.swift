import Foundation
import SwiftData

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let settingsRepository: SettingsRepository
    let modelContainer: ModelContainer
    let recurringExpenseRepository: RecurringExpenseRepository

    init(inMemory: Bool = false) {
        let container = PersistenceFactory.makeContainer(inMemory: inMemory)
        self.modelContainer = container
        let dataSource = SwiftDataExpenseDataSource(modelContainer: container)
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
        self.settingsRepository = UserDefaultsSettingsRepository()
        self.recurringExpenseRepository = InMemoryRecurringExpenseRepository()
    }

    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(repository: expenseRepository)
    }

    func makeExpenseListViewModel() -> ExpenseListViewModel {
        ExpenseListViewModel(repository: expenseRepository)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(repository: settingsRepository)
    }

    func makeAnalyticsViewModel() -> AnalyticsViewModel {
        AnalyticsViewModel(repository: expenseRepository)
    }

    func makeRecurringExpensesViewModel() -> RecurringExpensesViewModel {
        RecurringExpensesViewModel(repository: recurringExpenseRepository)
    }
}
