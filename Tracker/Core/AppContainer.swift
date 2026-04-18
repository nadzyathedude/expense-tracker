import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let settingsRepository: SettingsRepository

    init() {
        let dataSource = InMemoryExpenseDataSource()
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
        self.settingsRepository = UserDefaultsSettingsRepository()
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

    func makeRecurringSuggestionsViewModel() -> RecurringSuggestionsViewModel {
        RecurringSuggestionsViewModel(
            repository: expenseRepository,
            dismissedStore: UserDefaultsDismissedSuggestionsStore()
        )
    }
}
