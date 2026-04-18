import Foundation
import Testing
@testable import Tracker

@MainActor
@Suite("BudgetPlanningViewModel")
struct BudgetPlanningViewModelTests {
    @Test("load publishes success with computed summary")
    func loadPublishesSuccess() async throws {
        let expenseRepo = MockExpenseRepository()
        let april = YearMonth(year: 2026, month: 4)
        await expenseRepo.seed([
            Expense(title: "X", amount: 20, currency: .usd,
                    date: TestCalendar.date(year: 2026, month: 4, day: 1))
        ])
        let budgetRepo = MockBudgetRepository()
        let viewModel = makeViewModel(
            expenseRepo: expenseRepo,
            budgetRepo: budgetRepo,
            yearMonth: april
        )

        await viewModel.load()

        guard case let .success(summary) = viewModel.state else {
            Issue.record("Expected .success, got \(viewModel.state)")
            return
        }
        #expect(summary.totalSpent == Decimal(20))
    }

    @Test("setBudget reloads summary and emits budgetSaved")
    func setBudgetReloadsSummary() async throws {
        let expenseRepo = MockExpenseRepository()
        let budgetRepo = MockBudgetRepository()
        let april = YearMonth(year: 2026, month: 4)
        let viewModel = makeViewModel(
            expenseRepo: expenseRepo,
            budgetRepo: budgetRepo,
            yearMonth: april
        )

        await viewModel.load()
        await viewModel.setBudget(amount: 300, category: nil)

        #expect(viewModel.event == .budgetSaved)
        if case let .success(summary) = viewModel.state {
            #expect(summary.overallBudget == Decimal(300))
        } else {
            Issue.record("Expected .success after setBudget")
        }
    }

    @Test("setBudget rejects non-positive amount with event")
    func setBudgetRejectsNonPositive() async throws {
        let viewModel = makeViewModel(
            expenseRepo: MockExpenseRepository(),
            budgetRepo: MockBudgetRepository(),
            yearMonth: YearMonth(year: 2026, month: 4)
        )

        await viewModel.setBudget(amount: 0, category: nil)

        if case let .budgetFailed(message) = viewModel.event {
            #expect(message.contains("greater than zero"))
        } else {
            Issue.record("Expected .budgetFailed event")
        }
    }

    @Test("moveMonth advances year-month and reloads")
    func moveMonthAdvances() async throws {
        let viewModel = makeViewModel(
            expenseRepo: MockExpenseRepository(),
            budgetRepo: MockBudgetRepository(),
            yearMonth: YearMonth(year: 2026, month: 4)
        )
        await viewModel.load()

        await viewModel.moveMonth(by: 1)

        #expect(viewModel.yearMonth == YearMonth(year: 2026, month: 5))
    }

    private func makeViewModel(
        expenseRepo: ExpenseRepository,
        budgetRepo: BudgetRepository,
        yearMonth: YearMonth
    ) -> BudgetPlanningViewModel {
        let summary = DefaultGetMonthlyBudgetSummaryUseCase(
            expenseRepository: expenseRepo,
            budgetRepository: budgetRepo
        )
        let setBudget = DefaultSetMonthlyBudgetUseCase(repository: budgetRepo)
        return BudgetPlanningViewModel(
            summaryUseCase: summary,
            setBudgetUseCase: setBudget,
            currency: .usd,
            yearMonth: yearMonth,
            calendar: TestCalendar.gregorianUTC()
        )
    }
}
