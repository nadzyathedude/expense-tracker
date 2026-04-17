import Combine
import Foundation

enum BudgetPlanningEvent: Equatable {
    case budgetSaved
    case budgetFailed(String)
}

@MainActor
final class BudgetPlanningViewModel: ObservableObject {
    @Published private(set) var state: ViewState<BudgetSummary> = .idle
    @Published var yearMonth: YearMonth
    @Published var currency: Currency
    @Published var event: BudgetPlanningEvent?

    let availableCurrencies: [Currency] = Currency.all

    private let summaryUseCase: GetMonthlyBudgetSummaryUseCase
    private let setBudgetUseCase: SetMonthlyBudgetUseCase
    private let calendar: Calendar

    init(
        summaryUseCase: GetMonthlyBudgetSummaryUseCase,
        setBudgetUseCase: SetMonthlyBudgetUseCase,
        currency: Currency = .usd,
        yearMonth: YearMonth = .current(),
        calendar: Calendar = .current
    ) {
        self.summaryUseCase = summaryUseCase
        self.setBudgetUseCase = setBudgetUseCase
        self.currency = currency
        self.yearMonth = yearMonth
        self.calendar = calendar
    }

    func load() async {
        state = .loading
        do {
            let summary = try await summaryUseCase.execute(
                yearMonth: yearMonth,
                currency: currency,
                calendar: calendar
            )
            state = .success(summary)
        } catch {
            state = .failure("Couldn't load budget summary")
        }
    }

    func moveMonth(by delta: Int) async {
        yearMonth = yearMonth.advanced(byMonths: delta)
        await load()
    }

    func setCurrency(_ newCurrency: Currency) async {
        currency = newCurrency
        await load()
    }

    func setBudget(amount: Decimal, category: ExpenseCategory?) async {
        guard amount > 0 else {
            event = .budgetFailed("Budget must be greater than zero")
            return
        }
        do {
            _ = try await setBudgetUseCase.execute(
                yearMonth: yearMonth,
                category: category,
                amount: amount,
                currency: currency
            )
            event = .budgetSaved
            await load()
        } catch SetBudgetError.nonPositiveAmount {
            event = .budgetFailed("Budget must be greater than zero")
        } catch {
            event = .budgetFailed("Couldn't save budget")
        }
    }
}
