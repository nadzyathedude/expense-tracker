import Foundation

extension Currency {
    static func resolve(code: String) -> Currency {
        all.first { $0.code == code } ?? Currency(code: code, symbol: code, name: code)
    }
}
