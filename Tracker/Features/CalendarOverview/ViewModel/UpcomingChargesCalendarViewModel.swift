//
//  UpcomingChargesCalendarViewModel.swift
//  Tracker
//

import Foundation
import Combine

@MainActor
final class UpcomingChargesCalendarViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[UpcomingCharge]> = .idle
    @Published var displayedMonth: Date = Date()

    private let repository: RecurringExpenseRepository
    private let useCase: GetUpcomingChargesUseCase
    private let calendar: Calendar

    init(
        repository: RecurringExpenseRepository,
        useCase: GetUpcomingChargesUseCase? = nil,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.useCase = useCase ?? GetUpcomingChargesUseCase(calendar: calendar)
        self.calendar = calendar
    }

    func load() async {
        state = .loading
        do {
            let recurring = try await repository.fetchAll()
            let charges = useCase.execute(recurring: recurring, horizonDays: 90)
            state = .success(charges)
        } catch {
            state = .failure("Couldn't load upcoming charges.")
        }
    }

    func step(months delta: Int) {
        if let next = calendar.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = next
        }
    }

    var chargesByDay: [Date: [UpcomingCharge]] {
        guard case .success(let items) = state else { return [:] }
        return Dictionary(grouping: items) { calendar.startOfDay(for: $0.date) }
    }

    func totalFor(month: Date) -> [String: Decimal] {
        guard case .success(let items) = state else { return [:] }
        let interval = calendar.dateInterval(of: .month, for: month)
        return items
            .filter { interval?.contains($0.date) == true }
            .reduce(into: [:]) { accum, charge in
                accum[charge.currencyCode, default: 0] += charge.amount
            }
    }
}
