import Foundation
import SwiftData

@Model
final class BudgetPersistent {
    @Attribute(.unique) var id: UUID
    var year: Int
    var month: Int
    var categoryId: String?
    var amount: Decimal
    var currencyCode: String

    init(
        id: UUID,
        year: Int,
        month: Int,
        categoryId: String?,
        amount: Decimal,
        currencyCode: String
    ) {
        self.id = id
        self.year = year
        self.month = month
        self.categoryId = categoryId
        self.amount = amount
        self.currencyCode = currencyCode
    }

    static func from(domain: Budget) -> BudgetPersistent {
        BudgetPersistent(
            id: domain.id,
            year: domain.yearMonth.year,
            month: domain.yearMonth.month,
            categoryId: domain.category?.id,
            amount: domain.amount,
            currencyCode: domain.currency.code
        )
    }

    func apply(_ domain: Budget) {
        year = domain.yearMonth.year
        month = domain.yearMonth.month
        categoryId = domain.category?.id
        amount = domain.amount
        currencyCode = domain.currency.code
    }

    func toDomain() -> Budget {
        Budget(
            id: id,
            yearMonth: YearMonth(year: year, month: month),
            category: ExpenseCategory.resolve(id: categoryId),
            amount: amount,
            currency: Currency.resolve(code: currencyCode)
        )
    }
}
