//
//  RecurringSuggestionsViewModel.swift
//  Tracker
//

import Foundation
import Combine

@MainActor
final class RecurringSuggestionsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[RecurringCandidate]> = .idle

    private let repository: ExpenseRepository
    private let useCase: DetectRecurringExpensesUseCase
    private let dismissedStore: DismissedSuggestionsStore

    init(
        repository: ExpenseRepository,
        useCase: DetectRecurringExpensesUseCase? = nil,
        dismissedStore: DismissedSuggestionsStore
    ) {
        self.repository = repository
        self.useCase = useCase ?? DetectRecurringExpensesUseCase()
        self.dismissedStore = dismissedStore
    }

    func load() async {
        state = .loading
        do {
            let expenses = try await repository.all()
            let dismissed = dismissedStore.load()
            let candidates = useCase.execute(expenses: expenses, dismissedIds: dismissed)
            state = .success(candidates)
        } catch {
            state = .error("Couldn't detect recurring expenses.")
        }
    }

    func dismiss(_ candidate: RecurringCandidate) async {
        dismissedStore.dismiss(id: candidate.id)
        await load()
    }
}
