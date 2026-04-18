import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let settingsRepository: SettingsRepository
    let apiClient: APIClient
    let currencyRateRepository: CurrencyRateRepository
    let baseCurrencyStore: BaseCurrencyStore

    init() {
        let dataSource = InMemoryExpenseDataSource()
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

    func makeConvertCurrencyUseCase() -> ConvertCurrencyUseCase {
        ConvertCurrencyUseCase(repository: currencyRateRepository)
    }
}

private actor NullCurrencyRateCache: CurrencyRateCache {
    func load(base: String) async -> CurrencyRates? { nil }
    func save(_ rates: CurrencyRates) async {}
}
