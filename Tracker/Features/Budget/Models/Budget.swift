import Foundation

struct Budget: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let yearMonth: YearMonth
    let category: ExpenseCategory?
    let amount: Decimal
    let currency: Currency

    init(
        id: UUID = UUID(),
        yearMonth: YearMonth,
        category: ExpenseCategory? = nil,
        amount: Decimal,
        currency: Currency
    ) {
        self.id = id
        self.yearMonth = yearMonth
        self.category = category
        self.amount = amount
        self.currency = currency
    }

    var isOverall: Bool { category == nil }
}
