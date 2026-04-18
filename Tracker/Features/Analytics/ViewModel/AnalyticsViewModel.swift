//
//  AnalyticsViewModel.swift
//  Tracker
//

import Foundation
import Combine

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<SpendingSummary> = .idle
    @Published var selectedCurrency: Currency = .usd

    let availableCurrencies: [Currency] = Currency.all

    private let repository: ExpenseRepository
    private let useCase: ComputeSpendingSummaryUseCase

    init(
        repository: ExpenseRepository,
        useCase: ComputeSpendingSummaryUseCase? = nil
    ) {
        self.repository = repository
        self.useCase = useCase ?? ComputeSpendingSummaryUseCase()
    }

    func load() async {
        state = .loading
        do {
            let expenses = try await repository.fetchAll()
            let summary = useCase.execute(expenses: expenses, currencyCode: selectedCurrency.code)
            state = .success(summary)
        } catch {
            state = .failure("Couldn't compute analytics. Please try again.")
        }
    }
}
