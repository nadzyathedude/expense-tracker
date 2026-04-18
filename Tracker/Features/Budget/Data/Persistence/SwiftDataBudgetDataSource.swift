import Foundation
import SwiftData

@ModelActor
actor SwiftDataBudgetDataSource: BudgetDataSource {
    func fetch(yearMonth: YearMonth) async throws -> [Budget] {
        let year = yearMonth.year
        let month = yearMonth.month
        let descriptor = FetchDescriptor<BudgetPersistent>(
            predicate: #Predicate { $0.year == year && $0.month == month }
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func upsert(_ budget: Budget) async throws {
        if let existing = try fetchPersistent(id: budget.id) {
            existing.apply(budget)
            try modelContext.save()
            try removeDuplicatesOfSameKey(other: existing)
            return
        }

        try removeDuplicatesOfSameKey(matching: budget)

        modelContext.insert(BudgetPersistent.from(domain: budget))
        try modelContext.save()
    }

    func delete(id: UUID) async throws {
        if let existing = try fetchPersistent(id: id) {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }

    private func fetchPersistent(id: UUID) throws -> BudgetPersistent? {
        let descriptor = FetchDescriptor<BudgetPersistent>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    private func removeDuplicatesOfSameKey(matching budget: Budget) throws {
        let year = budget.yearMonth.year
        let month = budget.yearMonth.month
        let categoryId = budget.category?.id
        let currencyCode = budget.currency.code
        let descriptor = FetchDescriptor<BudgetPersistent>(
            predicate: #Predicate { entry in
                entry.year == year
                    && entry.month == month
                    && entry.categoryId == categoryId
                    && entry.currencyCode == currencyCode
            }
        )
        for entry in try modelContext.fetch(descriptor) {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }

    private func removeDuplicatesOfSameKey(other persistent: BudgetPersistent) throws {
        let year = persistent.year
        let month = persistent.month
        let categoryId = persistent.categoryId
        let currencyCode = persistent.currencyCode
        let keepId = persistent.id
        let descriptor = FetchDescriptor<BudgetPersistent>(
            predicate: #Predicate { entry in
                entry.id != keepId
                    && entry.year == year
                    && entry.month == month
                    && entry.categoryId == categoryId
                    && entry.currencyCode == currencyCode
            }
        )
        for entry in try modelContext.fetch(descriptor) {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }
}
