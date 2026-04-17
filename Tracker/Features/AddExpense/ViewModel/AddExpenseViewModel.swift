//
//  AddExpenseViewModel.swift
//  Tracker
//

import Foundation
import Combine

enum AddExpenseEvent: Equatable {
    case expenseAdded
    case showError(String)
}

@MainActor
final class AddExpenseViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var amountText: String = ""
    @Published var currency: Currency = .usd
    @Published private(set) var state: ViewState<Expense> = .idle
    @Published var event: AddExpenseEvent?

    let availableCurrencies: [Currency] = Currency.all

    private let repository: ExpenseRepository

    init(repository: ExpenseRepository) {
        self.repository = repository
    }

    var isSubmitEnabled: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && parsedAmount != nil
            && !state.isLoading
    }

    func addExpense() async {
        guard let amount = parsedAmount else {
            event = .showError("Please enter a valid amount")
            return
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else {
            event = .showError("Please enter a title")
            return
        }

        state = .loading
        let expense = Expense(title: trimmedTitle, amount: amount, currency: currency)

        do {
            try await repository.add(expense)
            state = .success(expense)
            event = .expenseAdded
            resetForm()
        } catch {
            state = .error("Couldn't save expense. Please try again.")
            event = .showError("Couldn't save expense. Please try again.")
        }
    }

    private var parsedAmount: Decimal? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else { return nil }
        return value
    }

    private func resetForm() {
        title = ""
        amountText = ""
    }
}
