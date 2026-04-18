//
//  AppContainer.swift
//  Tracker
//

import Foundation
import SwiftData

@MainActor
final class AppContainer {
    let expenseRepository: ExpenseRepository
    let modelContainer: ModelContainer

    init(cloudKit: Bool = true, inMemory: Bool = false) {
        let container = PersistenceFactory.makeContainer(cloudKit: cloudKit, inMemory: inMemory)
        self.modelContainer = container
        let dataSource = SwiftDataExpenseDataSource(modelContainer: container)
        self.expenseRepository = DefaultExpenseRepository(dataSource: dataSource)
    }

    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(repository: expenseRepository)
    }
}
