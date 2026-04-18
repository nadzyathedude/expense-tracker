import Foundation
import SwiftData

@Model
final class ExpensePersistent {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Decimal
    var currencyCode: String
    var categoryId: String?
    var date: Date

    init(
        id: UUID,
        title: String,
        amount: Decimal,
        currencyCode: String,
        categoryId: String?,
        date: Date
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currencyCode = currencyCode
        self.categoryId = categoryId
        self.date = date
    }

    static func from(domain: Expense) -> ExpensePersistent {
        ExpensePersistent(
            id: domain.id,
            title: domain.title,
            amount: domain.amount,
            currencyCode: domain.currency.code,
            categoryId: domain.category?.id,
            date: domain.date
        )
    }

    func apply(_ domain: Expense) {
        title = domain.title
        amount = domain.amount
        currencyCode = domain.currency.code
        categoryId = domain.category?.id
        date = domain.date
    }

    func toDomain() -> Expense {
        Expense(
            id: id,
            title: title,
            amount: amount,
            currency: Currency.resolve(code: currencyCode),
            category: ExpenseCategory.resolve(id: categoryId),
            date: date
        )
    }
}
