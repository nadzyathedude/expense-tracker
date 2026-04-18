import Foundation
import Testing
@testable import Tracker

@Suite("YearMonth")
struct YearMonthTests {
    @Test("contains returns true for dates inside the month")
    func containsInsideMonth() {
        let april = YearMonth(year: 2026, month: 4)
        let calendar = TestCalendar.gregorianUTC()
        #expect(april.contains(date: TestCalendar.date(year: 2026, month: 4, day: 1), calendar: calendar))
        #expect(april.contains(date: TestCalendar.date(year: 2026, month: 4, day: 30), calendar: calendar))
        #expect(!april.contains(date: TestCalendar.date(year: 2026, month: 3, day: 31), calendar: calendar))
        #expect(!april.contains(date: TestCalendar.date(year: 2026, month: 5, day: 1), calendar: calendar))
    }

    @Test("advanced handles year rollover")
    func advancedHandlesYearRollover() {
        let december = YearMonth(year: 2026, month: 12)
        #expect(december.advanced(byMonths: 1) == YearMonth(year: 2027, month: 1))
        #expect(december.advanced(byMonths: -12) == YearMonth(year: 2025, month: 12))
    }

    @Test("comparable orders chronologically")
    func comparableOrdersChronologically() {
        #expect(YearMonth(year: 2026, month: 1) < YearMonth(year: 2026, month: 2))
        #expect(YearMonth(year: 2025, month: 12) < YearMonth(year: 2026, month: 1))
    }
}
