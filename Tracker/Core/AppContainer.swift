//
//  AppContainer.swift
//  Tracker
//

import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let recurringExpenseRepository: RecurringExpenseRepository

    init() {
        let dataSource = InMemoryExpenseDataSource()
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
        self.recurringExpenseRepository = InMemoryRecurringExpenseRepository()
    }

    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(repository: expenseRepository)
    }

    func makeRecurringExpensesViewModel() -> RecurringExpensesViewModel {
        RecurringExpensesViewModel(repository: recurringExpenseRepository)
    }
}
