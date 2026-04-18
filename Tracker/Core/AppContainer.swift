import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let settingsRepository: SettingsRepository
    let recurringExpenseRepository: RecurringExpenseRepository

    init() {
        let dataSource = InMemoryExpenseDataSource()
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
        self.settingsRepository = UserDefaultsSettingsRepository()
        self.recurringExpenseRepository = InMemoryRecurringExpenseRepository()
    }

    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(repository: expenseRepository)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(repository: settingsRepository)
    }

    func makeRecurringExpensesViewModel() -> RecurringExpensesViewModel {
        RecurringExpensesViewModel(repository: recurringExpenseRepository)
    }
}
