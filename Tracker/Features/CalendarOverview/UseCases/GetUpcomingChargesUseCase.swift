//
//  GetUpcomingChargesUseCase.swift
//  Tracker
//

import Foundation

nonisolated struct UpcomingCharge: Identifiable, Hashable, Sendable {
    let id: UUID
    let recurringId: UUID
    let title: String
    let amount: Decimal
    let currencyCode: String
    let date: Date
}

nonisolated struct GetUpcomingChargesUseCase: Sendable {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func execute(recurring: [RecurringExpense], horizonDays: Int, from reference: Date = Date()) -> [UpcomingCharge] {
        guard horizonDays > 0 else { return [] }
        let startOfDay = calendar.startOfDay(for: reference)
        guard let horizonEnd = calendar.date(byAdding: .day, value: horizonDays, to: startOfDay) else {
            return []
        }

        var charges: [UpcomingCharge] = []
        for template in recurring {
            var date = template.nextDate
            var guard_ = 0
            while date < horizonEnd && guard_ < 366 {
                if date >= startOfDay {
                    charges.append(
                        UpcomingCharge(
                            id: UUID(),
                            recurringId: template.id,
                            title: template.title,
                            amount: template.amount,
                            currencyCode: template.currency.code,
                            date: date
                        )
                    )
                }
                date = template.frequency.advancing(from: date, calendar: calendar)
                guard_ += 1
            }
        }
        return charges.sorted { $0.date < $1.date }
    }
}
