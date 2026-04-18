import Foundation
import SwiftData

@ModelActor
actor SwiftDataExpenseDataSource: ExpenseDataSource {
    func save(_ expense: Expense) async throws {
        if let existing = try fetchPersistent(id: expense.id) {
            existing.apply(expense)
        } else {
            modelContext.insert(ExpensePersistent.from(domain: expense))
        }
        try modelContext.save()
    }

    func fetchAll() async throws -> [Expense] {
        let descriptor = FetchDescriptor<ExpensePersistent>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func fetch(in yearMonth: YearMonth, calendar: Calendar) async throws -> [Expense] {
        let range = monthRange(yearMonth: yearMonth, calendar: calendar)
        let lower = range.start
        let upper = range.end
        let descriptor = FetchDescriptor<ExpensePersistent>(
            predicate: #Predicate { $0.date >= lower && $0.date < upper },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    private func fetchPersistent(id: UUID) throws -> ExpensePersistent? {
        let descriptor = FetchDescriptor<ExpensePersistent>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    private func monthRange(yearMonth: YearMonth, calendar: Calendar) -> (start: Date, end: Date) {
        var startComponents = DateComponents()
        startComponents.year = yearMonth.year
        startComponents.month = yearMonth.month
        startComponents.day = 1
        let start = calendar.date(from: startComponents) ?? Date.distantPast

        let next = yearMonth.advanced(byMonths: 1)
        var endComponents = DateComponents()
        endComponents.year = next.year
        endComponents.month = next.month
        endComponents.day = 1
        let end = calendar.date(from: endComponents) ?? Date.distantFuture

        return (start, end)
    }
}
