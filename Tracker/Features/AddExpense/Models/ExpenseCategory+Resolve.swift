import Foundation

extension ExpenseCategory {
    static func resolve(id: String?) -> ExpenseCategory? {
        guard let id else {
            return nil
        }
        return all.first { $0.id == id }
    }
}
