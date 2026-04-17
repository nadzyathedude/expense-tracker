import Foundation
import Testing
@testable import Tracker

@Suite("GetMonthlyBudgetSummaryUseCase")
struct GetMonthlyBudgetSummaryUseCaseTests {
    private let april = YearMonth(year: 2026, month: 4)
    private let calendar = TestCalendar.gregorianUTC()

    @Test("computes total spent filtered by month and currency")
    func totalSpentFilteredByMonthAndCurrency() async throws {
        let expenseRepo = MockExpenseRepository()
        await expenseRepo.seed([
            Expense(title: "A", amount: 10, currency: .usd,
                    date: TestCalendar.date(year: 2026, month: 4, day: 5)),
            Expense(title: "B", amount: 20, currency: .usd,
                    date: TestCalendar.date(year: 2026, month: 4, day: 10)),
            Expense(title: "C outside month", amount: 99, currency: .usd,
                    date: TestCalendar.date(year: 2026, month: 3, day: 31)),
            Expense(title: "D wrong currency", amount: 500, currency: .eur,
                    date: TestCalendar.date(year: 2026, month: 4, day: 15))
        ])
        let budgetRepo = MockBudgetRepository()

        let useCase = DefaultGetMonthlyBudgetSummaryUseCase(
            expenseRepository: expenseRepo,
            budgetRepository: budgetRepo
        )

        let summary = try await useCase.execute(
            yearMonth: april,
            currency: .usd,
            calendar: calendar
        )

        #expect(summary.totalSpent == Decimal(30))
        #expect(summary.overallBudget == nil)
        #expect(summary.remaining == nil)
        #expect(summary.progress == nil)
    }

    @Test("includes overall budget and category breakdowns")
    func overallBudgetAndCategoryBreakdowns() async throws {
        let expenseRepo = MockExpenseRepository()
        await expenseRepo.seed([
            Expense(title: "Coffee", amount: 5, currency: .usd, category: .coffee,
                    date: TestCalendar.date(year: 2026, month: 4, day: 2)),
            Expense(title: "Coffee", amount: 7, currency: .usd, category: .coffee,
                    date: TestCalendar.date(year: 2026, month: 4, day: 6)),
            Expense(title: "Bus", amount: 3, currency: .usd, category: .transport,
                    date: TestCalendar.date(year: 2026, month: 4, day: 8))
        ])
        let budgetRepo = MockBudgetRepository()
        await budgetRepo.seed([
            Budget(yearMonth: april, category: nil, amount: 100, currency: .usd),
            Budget(yearMonth: april, category: .coffee, amount: 15, currency: .usd)
        ])

        let useCase = DefaultGetMonthlyBudgetSummaryUseCase(
            expenseRepository: expenseRepo,
            budgetRepository: budgetRepo
        )

        let summary = try await useCase.execute(
            yearMonth: april,
            currency: .usd,
            calendar: calendar
        )

        #expect(summary.overallBudget == Decimal(100))
        #expect(summary.totalSpent == Decimal(15))
        #expect(summary.remaining == Decimal(85))

        let coffee = try #require(summary.categoryBreakdowns.first { $0.category == .coffee })
        #expect(coffee.budget == Decimal(15))
        #expect(coffee.spent == Decimal(12))
        #expect(coffee.remaining == Decimal(3))
        #expect(coffee.isOverBudget == false)

        let transport = try #require(summary.categoryBreakdowns.first { $0.category == .transport })
        #expect(transport.budget == nil)
        #expect(transport.spent == Decimal(3))
    }

    @Test("flags over budget when spent exceeds cap")
    func flagsOverBudget() async throws {
        let expenseRepo = MockExpenseRepository()
        await expenseRepo.seed([
            Expense(title: "Big", amount: 150, currency: .usd,
                    date: TestCalendar.date(year: 2026, month: 4, day: 10))
        ])
        let budgetRepo = MockBudgetRepository()
        await budgetRepo.seed([
            Budget(yearMonth: april, category: nil, amount: 100, currency: .usd)
        ])

        let useCase = DefaultGetMonthlyBudgetSummaryUseCase(
            expenseRepository: expenseRepo,
            budgetRepository: budgetRepo
        )

        let summary = try await useCase.execute(
            yearMonth: april,
            currency: .usd,
            calendar: calendar
        )

        #expect(summary.isOverBudget)
        #expect(summary.remaining == Decimal(-50))
        #expect(summary.progress == 1.0)
    }
}
