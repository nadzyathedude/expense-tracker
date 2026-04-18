import Combine
import Foundation

enum AddExpenseEvent: Equatable {
    case added(Expense)
    case failed(String)
}

@MainActor
final class AddExpenseViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var amountText: String = ""
    @Published var currency: Currency = .usd
    @Published var category: Category = .other
    @Published private(set) var state: ViewState<Expense> = .idle
    @Published var event: AddExpenseEvent?

    let availableCurrencies: [Currency] = Currency.all
    let availableCategories: [Category] = Category.all

    private let repository: ExpenseRepository

    init(repository: ExpenseRepository) {
        self.repository = repository
    }

    var canSubmit: Bool {
        guard !state.isLoading else {
            return false
        }
        guard !trimmedTitle.isEmpty else {
            return false
        }
        return parsedAmount != nil
    }

    func submit() async {
        guard let amount = parsedAmount else {
            event = .failed("Please enter a valid amount")
            return
        }

        let title = trimmedTitle
        guard !title.isEmpty else {
            event = .failed("Please enter a title")
            return
        }

        state = .loading
        let expense = Expense(
            title: title,
            amount: amount,
            currency: currency,
            category: category
        )

        do {
            try await repository.add(expense)
            state = .success(expense)
            event = .added(expense)
            resetForm()
        } catch {
            state = .failure("Couldn't save expense. Please try again.")
            event = .failed("Couldn't save expense. Please try again.")
        }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespaces)
    }

    private var parsedAmount: Decimal? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else {
            return nil
        }
        return value
    }

    private func resetForm() {
        title = ""
        amountText = ""
    }
}
