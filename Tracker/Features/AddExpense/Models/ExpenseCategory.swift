import Foundation

struct ExpenseCategory: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let name: String
    let icon: String
}

extension ExpenseCategory {
    static let food = ExpenseCategory(id: "food", name: "Food", icon: "fork.knife")
    static let transport = ExpenseCategory(id: "transport", name: "Transport", icon: "car.fill")
    static let coffee = ExpenseCategory(id: "coffee", name: "Coffee", icon: "cup.and.saucer.fill")
    static let bills = ExpenseCategory(id: "bills", name: "Bills", icon: "doc.text.fill")
    static let shopping = ExpenseCategory(id: "shopping", name: "Shopping", icon: "bag.fill")
    static let entertainment = ExpenseCategory(id: "entertainment", name: "Entertainment", icon: "film.fill")
    static let health = ExpenseCategory(id: "health", name: "Health", icon: "heart.fill")
    static let other = ExpenseCategory(id: "other", name: "Other", icon: "square.grid.2x2.fill")

    static let all: [ExpenseCategory] = [
        .food, .transport, .coffee, .bills,
        .shopping, .entertainment, .health, .other
    ]
}
