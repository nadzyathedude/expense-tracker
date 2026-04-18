import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let settingsRepository: SettingsRepository
    let biometricService: BiometricAuthService
    let appLockPreferences: AppLockPreferencesStore

    init() {
        let dataSource = InMemoryExpenseDataSource()
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
        self.settingsRepository = UserDefaultsSettingsRepository()
        self.biometricService = LocalAuthBiometricService()
        self.appLockPreferences = UserDefaultsAppLockPreferencesStore()
    }

    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(repository: expenseRepository)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(repository: settingsRepository)
    }

    func makeAppLockViewModel() -> AppLockViewModel {
        AppLockViewModel(service: biometricService, preferences: appLockPreferences)
    }
}
