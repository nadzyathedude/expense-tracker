import Foundation

struct BudgetSummary: Equatable, Sendable {
    let yearMonth: YearMonth
    let currency: Currency
    let overallBudget: Decimal?
    let totalSpent: Decimal
    let categoryBreakdowns: [CategoryBudgetBreakdown]

    var remaining: Decimal? {
        guard let overallBudget else {
            return nil
        }
        return overallBudget - totalSpent
    }

    var progress: Double? {
        guard let overallBudget, overallBudget > 0 else {
            return nil
        }
        let raw = NSDecimalNumber(decimal: totalSpent).doubleValue
            / NSDecimalNumber(decimal: overallBudget).doubleValue
        return min(max(raw, 0), 1)
    }

    var isOverBudget: Bool {
        guard let overallBudget else {
            return false
        }
        return totalSpent > overallBudget
    }
}

struct CategoryBudgetBreakdown: Identifiable, Equatable, Sendable {
    let category: ExpenseCategory
    let budget: Decimal?
    let spent: Decimal

    var id: String { category.id }

    var remaining: Decimal? {
        guard let budget else {
            return nil
        }
        return budget - spent
    }

    var progress: Double? {
        guard let budget, budget > 0 else {
            return nil
        }
        let raw = NSDecimalNumber(decimal: spent).doubleValue
            / NSDecimalNumber(decimal: budget).doubleValue
        return min(max(raw, 0), 1)
    }

    var isOverBudget: Bool {
        guard let budget else {
            return false
        }
        return spent > budget
    }
}
