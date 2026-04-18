import Foundation
import Testing
@testable import Tracker

@Suite("SetMonthlyBudgetUseCase")
struct SetMonthlyBudgetUseCaseTests {
    @Test("persists valid budget through repository")
    func persistsValidBudget() async throws {
        let repo = MockBudgetRepository()
        let useCase = DefaultSetMonthlyBudgetUseCase(repository: repo)
        let yearMonth = YearMonth(year: 2026, month: 4)

        let budget = try await useCase.execute(
            yearMonth: yearMonth,
            category: .coffee,
            amount: 50,
            currency: .usd
        )

        let stored = try await repo.budgets(for: yearMonth)
        #expect(stored.count == 1)
        #expect(stored.first?.amount == Decimal(50))
        #expect(budget.isOverall == false)
    }

    @Test("rejects non-positive amount")
    func rejectsNonPositiveAmount() async throws {
        let repo = MockBudgetRepository()
        let useCase = DefaultSetMonthlyBudgetUseCase(repository: repo)

        await #expect(throws: SetBudgetError.nonPositiveAmount) {
            _ = try await useCase.execute(
                yearMonth: YearMonth(year: 2026, month: 4),
                category: nil,
                amount: 0,
                currency: .usd
            )
        }
    }
}
