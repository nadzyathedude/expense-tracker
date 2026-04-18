import Foundation

struct Currency: Identifiable, Hashable, Codable {
    let code: String
    let symbol: String
    let name: String

    var id: String { code }
}

extension Currency {
    static let usd = Currency(code: "USD", symbol: "$", name: "US Dollar")
    static let eur = Currency(code: "EUR", symbol: "€", name: "Euro")
    static let gbp = Currency(code: "GBP", symbol: "£", name: "British Pound")
    static let jpy = Currency(code: "JPY", symbol: "¥", name: "Japanese Yen")
    static let cad = Currency(code: "CAD", symbol: "C$", name: "Canadian Dollar")
    static let aud = Currency(code: "AUD", symbol: "A$", name: "Australian Dollar")
    static let chf = Currency(code: "CHF", symbol: "Fr", name: "Swiss Franc")
    static let cny = Currency(code: "CNY", symbol: "¥", name: "Chinese Yuan")
    static let rub = Currency(code: "RUB", symbol: "₽", name: "Russian Ruble")

    static let all: [Currency] = [.usd, .eur, .gbp, .jpy, .cad, .aud, .chf, .cny, .rub]
}
