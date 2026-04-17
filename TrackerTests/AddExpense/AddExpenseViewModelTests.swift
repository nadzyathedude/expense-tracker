import Foundation
import Testing
@testable import Tracker

@MainActor
@Suite("AddExpenseViewModel")
struct AddExpenseViewModelTests {
    @Test("canSubmit is false when title or amount missing")
    func canSubmitFalseWhenIncomplete() async throws {
        let viewModel = AddExpenseViewModel(repository: MockExpenseRepository())
        #expect(viewModel.canSubmit == false)

        viewModel.title = "Coffee"
        #expect(viewModel.canSubmit == false)

        viewModel.amountText = "3.50"
        #expect(viewModel.canSubmit == true)
    }

    @Test("submit persists expense with selected fields and resets form")
    func submitPersistsAndResets() async throws {
        let repo = MockExpenseRepository()
        let viewModel = AddExpenseViewModel(repository: repo)
        viewModel.title = "Flat White"
        viewModel.amountText = "4.75"
        viewModel.currency = .eur
        viewModel.category = .coffee
        viewModel.date = TestCalendar.date(year: 2026, month: 4, day: 17)

        await viewModel.submit()

        let all = try await repo.all()
        #expect(all.count == 1)
        let saved = try #require(all.first)
        #expect(saved.title == "Flat White")
        #expect(saved.amount == Decimal(string: "4.75"))
        #expect(saved.currency == .eur)
        #expect(saved.category == .coffee)
        #expect(viewModel.title.isEmpty)
        #expect(viewModel.amountText.isEmpty)
        #expect(viewModel.category == nil)
    }

    @Test("submit rejects invalid amount with failure event")
    func submitRejectsInvalidAmount() async throws {
        let viewModel = AddExpenseViewModel(repository: MockExpenseRepository())
        viewModel.title = "X"
        viewModel.amountText = "-5"

        await viewModel.submit()

        if case let .failed(message) = viewModel.event {
            #expect(message.contains("valid amount"))
        } else {
            Issue.record("Expected failed event")
        }
    }
}
