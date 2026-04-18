//
//  SwiftDataExpenseDataSource.swift
//  Tracker
//

import Foundation
import SwiftData

@ModelActor
actor SwiftDataExpenseDataSource: ExpenseDataSource {
    func save(_ expense: Expense) async throws {
        let record = ExpenseRecord(expense: expense)
        modelContext.insert(record)
        try modelContext.save()
    }

    func fetchAll() async throws -> [Expense] {
        let descriptor = FetchDescriptor<ExpenseRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let records = try modelContext.fetch(descriptor)
        return records.map { $0.toExpense() }
    }
}

enum PersistenceFactory {
    @MainActor
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([ExpenseRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
