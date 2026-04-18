import Foundation

struct Expense: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let title: String
    let amount: Decimal
    let currency: Currency
    let category: ExpenseCategory?
    let date: Date

    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        currency: Currency,
        category: ExpenseCategory? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currency = currency
        self.category = category
        self.date = date
    }
}
