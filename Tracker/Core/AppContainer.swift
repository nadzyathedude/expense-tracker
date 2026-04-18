//
//  AppContainer.swift
//  Tracker
//

import Foundation

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository

    init() {
        let dataSource = InMemoryExpenseDataSource()
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
    }

    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(repository: expenseRepository)
    }

    func makeExportViewModel() -> ExportViewModel {
        ExportViewModel(useCase: ExportUseCase(repository: expenseRepository))
    }
}
