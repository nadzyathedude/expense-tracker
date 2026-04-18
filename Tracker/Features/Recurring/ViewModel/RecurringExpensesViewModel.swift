//
//  RecurringExpensesViewModel.swift
//  Tracker
//

import Foundation
import Combine

@MainActor
final class RecurringExpensesViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[RecurringExpense]> = .idle

    private let repository: RecurringExpenseRepository

    init(repository: RecurringExpenseRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let items = try await repository.fetchAll()
            state = .success(items)
        } catch {
            state = .error("Couldn't load recurring expenses.")
        }
    }

    func add(_ recurring: RecurringExpense) async {
        do {
            try await repository.add(recurring)
            await load()
        } catch {
            state = .error("Couldn't save recurring expense.")
        }
    }

    func delete(id: UUID) async {
        do {
            try await repository.delete(id: id)
            await load()
        } catch {
            state = .error("Couldn't delete recurring expense.")
        }
    }
}
