import Foundation

struct YearMonth: Hashable, Codable, Sendable, Comparable {
    let year: Int
    let month: Int

    init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }

    static func current(now: Date = Date(), calendar: Calendar = .current) -> YearMonth {
        let components = calendar.dateComponents([.year, .month], from: now)
        return YearMonth(year: components.year ?? 1970, month: components.month ?? 1)
    }

    static func from(date: Date, calendar: Calendar = .current) -> YearMonth {
        let components = calendar.dateComponents([.year, .month], from: date)
        return YearMonth(year: components.year ?? 1970, month: components.month ?? 1)
    }

    func contains(date: Date, calendar: Calendar = .current) -> Bool {
        YearMonth.from(date: date, calendar: calendar) == self
    }

    func advanced(byMonths delta: Int) -> YearMonth {
        let total = year * 12 + (month - 1) + delta
        return YearMonth(year: total / 12, month: (total % 12) + 1)
    }

    func displayString(locale: Locale = .current) -> String {
        var components = DateComponents()
        components.year = year
        components.month = month
        let calendar = Calendar(identifier: .gregorian)
        guard let date = calendar.date(from: components) else {
            return "\(year)-\(month)"
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }
        return lhs.month < rhs.month
    }
}
