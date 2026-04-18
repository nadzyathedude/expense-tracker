//
//  DetectRecurringExpensesUseCase.swift
//  Tracker
//

import Foundation

nonisolated struct RecurringCandidate: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let averageAmount: Decimal
    let currencyCode: String
    let intervalDays: Int
    let occurrences: Int
    let lastSeen: Date
}

nonisolated struct DetectRecurringExpensesUseCase: Sendable {
    let calendar: Calendar
    let amountTolerance: Double
    let minOccurrences: Int

    init(
        calendar: Calendar = .current,
        amountTolerance: Double = 0.10,
        minOccurrences: Int = 3
    ) {
        self.calendar = calendar
        self.amountTolerance = amountTolerance
        self.minOccurrences = minOccurrences
    }

    func execute(expenses: [Expense], dismissedIds: Set<String> = []) -> [RecurringCandidate] {
        let groups = Dictionary(grouping: expenses) { expense in
            Self.normalize(expense.title) + "|" + expense.currency.code
        }

        var candidates: [RecurringCandidate] = []

        for (key, bucket) in groups where bucket.count >= minOccurrences {
            guard !dismissedIds.contains(key) else { continue }
            let sorted = bucket.sorted { $0.createdAt < $1.createdAt }
            guard let averageInterval = averageDayInterval(sorted.map { $0.createdAt }),
                  let frequency = closestFrequency(to: averageInterval) else { continue }

            let amounts = sorted.map { NSDecimalNumber(decimal: $0.amount).doubleValue }
            guard amountsWithinTolerance(amounts) else { continue }

            let average = amounts.reduce(0, +) / Double(amounts.count)
            guard let averageDecimal = Decimal(string: String(average)) else { continue }

            candidates.append(
                RecurringCandidate(
                    id: key,
                    title: sorted.first?.title ?? key,
                    averageAmount: averageDecimal,
                    currencyCode: bucket.first?.currency.code ?? "USD",
                    intervalDays: frequency,
                    occurrences: bucket.count,
                    lastSeen: sorted.last?.createdAt ?? Date()
                )
            )
        }

        return candidates.sorted { $0.lastSeen > $1.lastSeen }
    }

    private static func normalize(_ title: String) -> String {
        title
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func amountsWithinTolerance(_ amounts: [Double]) -> Bool {
        guard let average = amounts.isEmpty ? nil : amounts.reduce(0, +) / Double(amounts.count), average > 0 else {
            return false
        }
        return amounts.allSatisfy { abs($0 - average) / average <= amountTolerance }
    }

    private func averageDayInterval(_ dates: [Date]) -> Double? {
        guard dates.count >= 2 else { return nil }
        var intervals: [Double] = []
        for index in 1..<dates.count {
            let delta = dates[index].timeIntervalSince(dates[index - 1])
            intervals.append(delta / 86_400)
        }
        return intervals.reduce(0, +) / Double(intervals.count)
    }

    private func closestFrequency(to intervalDays: Double) -> Int? {
        let candidates: [Int] = [7, 14, 30, 90, 365]
        return candidates.min(by: { abs(Double($0) - intervalDays) < abs(Double($1) - intervalDays) })
            .flatMap { candidate in
                abs(Double(candidate) - intervalDays) / Double(candidate) <= 0.15 ? candidate : nil
            }
    }
}
