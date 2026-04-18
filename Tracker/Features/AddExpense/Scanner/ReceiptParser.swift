//
//  ReceiptParser.swift
//  Tracker
//

import Foundation

nonisolated struct ParsedReceipt: Equatable, Sendable {
    var amount: Decimal?
    var merchant: String?
    var date: Date?
}

nonisolated struct ReceiptParser: Sendable {
    let calendar: Calendar
    let locale: Locale

    init(calendar: Calendar = .current, locale: Locale = .current) {
        self.calendar = calendar
        self.locale = locale
    }

    func parse(lines: [String]) -> ParsedReceipt {
        let trimmed = lines.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        return ParsedReceipt(
            amount: findAmount(in: trimmed),
            merchant: findMerchant(in: trimmed),
            date: findDate(in: trimmed)
        )
    }

    private func findAmount(in lines: [String]) -> Decimal? {
        let pattern = try? NSRegularExpression(pattern: #"(\d+[.,]\d{2})"#)
        var candidates: [(Decimal, Int)] = []

        for (index, line) in lines.enumerated() {
            guard let pattern else { continue }
            let range = NSRange(line.startIndex..., in: line)
            let matches = pattern.matches(in: line, range: range)
            for match in matches {
                guard let swiftRange = Range(match.range(at: 1), in: line) else { continue }
                let raw = line[swiftRange].replacingOccurrences(of: ",", with: ".")
                guard let value = Decimal(string: raw), value > 0 else { continue }
                let score = score(for: line, index: index, totalLines: lines.count)
                candidates.append((value, score))
            }
        }

        return candidates
            .sorted { ($0.1, NSDecimalNumber(decimal: $0.0).doubleValue) > ($1.1, NSDecimalNumber(decimal: $1.0).doubleValue) }
            .first?
            .0
    }

    private func score(for line: String, index: Int, totalLines: Int) -> Int {
        let lower = line.lowercased()
        var score = 0
        if lower.contains("total") || lower.contains("итого") || lower.contains("сумма") {
            score += 5
        }
        if lower.contains("subtotal") || lower.contains("tax") || lower.contains("ндс") {
            score -= 2
        }
        score += max(0, index - totalLines / 2)
        return score
    }

    private func findMerchant(in lines: [String]) -> String? {
        for line in lines.prefix(3) {
            let letters = line.filter { $0.isLetter }
            if letters.count >= 3 {
                return line
            }
        }
        return lines.first
    }

    private func findDate(in lines: [String]) -> Date? {
        let formats = ["dd.MM.yyyy", "dd/MM/yyyy", "yyyy-MM-dd", "MM/dd/yyyy"]
        let formatter = DateFormatter()
        formatter.locale = locale
        for format in formats {
            formatter.dateFormat = format
            for line in lines {
                if let date = formatter.date(from: line) { return date }
                for token in line.split(whereSeparator: { !$0.isNumber && $0 != "." && $0 != "-" && $0 != "/" }) {
                    if let date = formatter.date(from: String(token)) { return date }
                }
            }
        }
        return nil
    }
}
