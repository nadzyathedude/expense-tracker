import Foundation

enum MoneyFormatter {
    static func string(amount: Decimal, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let number = NSDecimalNumber(decimal: amount)
        let formatted = formatter.string(from: number) ?? "0"
        return "\(currency.symbol)\(formatted)"
    }
}
