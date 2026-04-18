import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let settingsRepository: SettingsRepository
    let budgetRepository: BudgetRepository
    let notificationService: NotificationService

    init() {
        let dataSource = InMemoryExpenseDataSource()
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
        self.settingsRepository = UserDefaultsSettingsRepository()
        self.budgetRepository = InMemoryBudgetRepository()
        self.notificationService = LocalNotificationService()
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

    func makeBudgetsViewModel() -> BudgetsViewModel {
        BudgetsViewModel(repository: budgetRepository, notifications: notificationService)
    }
}
