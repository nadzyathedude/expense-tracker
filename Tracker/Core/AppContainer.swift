//
//  AppContainer.swift
//  Tracker
//

import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let budgetRepository: BudgetRepository
    let notificationService: NotificationService

    init() {
        let dataSource = InMemoryExpenseDataSource()
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
        self.budgetRepository = InMemoryBudgetRepository()
        self.notificationService = LocalNotificationService()
    }

    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(repository: expenseRepository)
    }

    func makeBudgetsViewModel() -> BudgetsViewModel {
        BudgetsViewModel(repository: budgetRepository, notifications: notificationService)
    }
}
