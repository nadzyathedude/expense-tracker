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

nonisolated enum PersistenceFactory {
    @MainActor
    static func makeContainer(cloudKit: Bool = true, inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([ExpenseRecord.self])
        let config: ModelConfiguration
        if inMemory {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else if cloudKit {
            config = ModelConfiguration(schema: schema, cloudKitDatabase: .private("iCloud.Dmitriy.Tracker"))
        } else {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            if cloudKit {
                let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                if let container = try? ModelContainer(for: schema, configurations: [fallback]) {
                    return container
                }
            }
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
