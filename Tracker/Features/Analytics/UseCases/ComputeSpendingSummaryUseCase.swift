//
//  ComputeSpendingSummaryUseCase.swift
//  Tracker
//

import Foundation

struct DailyTotal: Identifiable, Hashable {
    let date: Date
    let total: Decimal
    var id: Date { date }
}

struct CurrencyTotal: Identifiable, Hashable {
    let currencyCode: String
    let total: Decimal
    var id: String { currencyCode }
}

struct SpendingSummary: Equatable {
    let today: Decimal
    let thisWeek: Decimal
    let thisMonth: Decimal
    let daily: [DailyTotal]
    let byCurrency: [CurrencyTotal]
}

struct ComputeSpendingSummaryUseCase {
    let calendar: Calendar
    let now: () -> Date

    init(calendar: Calendar = .current, now: @escaping () -> Date = Date.init) {
        self.calendar = calendar
        self.now = now
    }

    func execute(expenses: [Expense], currencyCode: String, trailingDays: Int = 30) -> SpendingSummary {
        let filtered = expenses.filter { $0.currency.code == currencyCode }
        let reference = now()

        let today = sum(filtered, since: calendar.startOfDay(for: reference))
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: reference)) ?? reference
        let weekTotal = sum(filtered, since: weekStart)
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: reference)) ?? reference
        let monthTotal = sum(filtered, since: monthStart)

        return SpendingSummary(
            today: today,
            thisWeek: weekTotal,
            thisMonth: monthTotal,
            daily: dailyTotals(filtered, days: trailingDays, reference: reference),
            byCurrency: totalsByCurrency(expenses)
        )
    }

    private func sum(_ expenses: [Expense], since: Date) -> Decimal {
        expenses
            .filter { $0.createdAt >= since }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }

    private func dailyTotals(_ expenses: [Expense], days: Int, reference: Date) -> [DailyTotal] {
        let start = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: reference)) ?? reference
        var buckets: [Date: Decimal] = [:]
        for offset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: offset, to: start) {
                buckets[date] = 0
            }
        }
        for expense in expenses where expense.createdAt >= start {
            let day = calendar.startOfDay(for: expense.createdAt)
            buckets[day, default: 0] += expense.amount
        }
        return buckets
            .map { DailyTotal(date: $0.key, total: $0.value) }
            .sorted { $0.date < $1.date }
    }

    private func totalsByCurrency(_ expenses: [Expense]) -> [CurrencyTotal] {
        var buckets: [String: Decimal] = [:]
        for expense in expenses {
            buckets[expense.currency.code, default: 0] += expense.amount
        }
        return buckets
            .map { CurrencyTotal(currencyCode: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }
}
