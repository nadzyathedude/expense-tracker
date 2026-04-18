//
//  AppContainer.swift
//  Tracker
//

import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let biometricService: BiometricAuthService
    let appLockPreferences: AppLockPreferencesStore

    init() {
        let dataSource = InMemoryExpenseDataSource()
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
        self.biometricService = LocalAuthBiometricService()
        self.appLockPreferences = UserDefaultsAppLockPreferencesStore()
    }

    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(repository: expenseRepository)
    }

    func makeAppLockViewModel() -> AppLockViewModel {
        AppLockViewModel(service: biometricService, preferences: appLockPreferences)
    }
}
