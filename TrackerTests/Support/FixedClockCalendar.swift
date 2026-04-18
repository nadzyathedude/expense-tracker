import Foundation

enum TestCalendar {
    static func gregorianUTC() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        return calendar
    }

    static func date(year: Int, month: Int, day: Int) -> Date {
        let calendar = gregorianUTC()
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components) ?? Date()
    }
}
