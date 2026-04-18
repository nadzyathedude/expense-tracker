//
//  ExpenseListViewModel.swift
//  Tracker
//

import Foundation
import Combine

@MainActor
final class ExpenseListViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[Expense]> = .idle

    private let repository: ExpenseRepository

    init(repository: ExpenseRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let items = try await repository.fetchAll()
            let sorted = items.sorted { $0.createdAt > $1.createdAt }
            state = .success(sorted)
        } catch {
            state = .failure("Couldn't load expenses. Pull to retry.")
        }
    }
}
