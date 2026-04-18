import Foundation
import SwiftData

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let settingsRepository: SettingsRepository
    let modelContainer: ModelContainer
    let apiClient: APIClient
    let currencyRateRepository: CurrencyRateRepository
    let baseCurrencyStore: BaseCurrencyStore
    let recurringExpenseRepository: RecurringExpenseRepository
    let budgetRepository: BudgetRepository
    let notificationService: NotificationService

    init(cloudKit: Bool = true, inMemory: Bool = false) {
        let container = PersistenceFactory.makeContainer(cloudKit: cloudKit, inMemory: inMemory)
        self.modelContainer = container
        let dataSource = SwiftDataExpenseDataSource(modelContainer: container)
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
        self.settingsRepository = UserDefaultsSettingsRepository()

        let client = URLSessionAPIClient()
        self.apiClient = client

        let cache: CurrencyRateCache
        do {
            cache = try DiskCurrencyRateCache()
        } catch {
            cache = NullCurrencyRateCache()
        }
        self.currencyRateRepository = DefaultCurrencyRateRepository(client: client, cache: cache)
        self.baseCurrencyStore = UserDefaultsBaseCurrencyStore()

        self.recurringExpenseRepository = InMemoryRecurringExpenseRepository()

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

    func makeAnalyticsViewModel() -> AnalyticsViewModel {
        AnalyticsViewModel(repository: expenseRepository)
    }

    func makeConvertCurrencyUseCase() -> ConvertCurrencyUseCase {
        ConvertCurrencyUseCase(repository: currencyRateRepository)
    }

    func makeUpcomingChargesCalendarViewModel() -> UpcomingChargesCalendarViewModel {
        UpcomingChargesCalendarViewModel(repository: recurringExpenseRepository)
    }

    func makeBudgetsViewModel() -> BudgetsViewModel {
        BudgetsViewModel(repository: budgetRepository, notifications: notificationService)
    }

    func makeRecurringExpensesViewModel() -> RecurringExpensesViewModel {
        RecurringExpensesViewModel(repository: recurringExpenseRepository)
    }

    func makeExportViewModel() -> ExportViewModel {
        ExportViewModel(useCase: ExportUseCase(repository: expenseRepository))
    }

    func makeRecurringSuggestionsViewModel() -> RecurringSuggestionsViewModel {
        RecurringSuggestionsViewModel(
            repository: expenseRepository,
            dismissedStore: UserDefaultsDismissedSuggestionsStore()
        )
    }
}

private actor NullCurrencyRateCache: CurrencyRateCache {
    func load(base: String) async -> CurrencyRates? { nil }
    func save(_ rates: CurrencyRates) async {}
}
