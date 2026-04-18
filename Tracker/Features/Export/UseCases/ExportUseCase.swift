//
//  ExportUseCase.swift
//  Tracker
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

nonisolated enum ExportFormat: String, CaseIterable, Identifiable, Sendable {
    case csv
    case pdf

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .csv: return "CSV"
        case .pdf: return "PDF"
        }
    }

    var fileExtension: String { rawValue }
}

nonisolated struct ExportedFile: Sendable {
    let url: URL
    let format: ExportFormat
}

nonisolated struct ExportUseCase: Sendable {
    let repository: ExpenseRepository
    let fileManager: FileManager

    init(repository: ExpenseRepository, fileManager: FileManager = .default) {
        self.repository = repository
        self.fileManager = fileManager
    }

    func execute(range: DateInterval, format: ExportFormat) async throws -> ExportedFile {
        let all = try await repository.all()
        let filtered = all
            .filter { range.contains($0.createdAt) }
            .sorted { $0.createdAt < $1.createdAt }

        let directory = try exportDirectory()
        let fileName = "expenses-\(stamp()).\(format.fileExtension)"
        let url = directory.appendingPathComponent(fileName)

        switch format {
        case .csv:
            let data = Data(csv(for: filtered).utf8)
            try data.write(to: url, options: .atomic)
        case .pdf:
            let data = pdf(for: filtered, range: range)
            try data.write(to: url, options: .atomic)
        }

        return ExportedFile(url: url, format: format)
    }

    private func exportDirectory() throws -> URL {
        let caches = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = caches.appendingPathComponent("Exports", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private func stamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: Date())
    }

    private func csv(for expenses: [Expense]) -> String {
        var rows = ["Date,Title,Amount,Currency"]
        let dateFormatter = ISO8601DateFormatter()
        for expense in expenses {
            let date = dateFormatter.string(from: expense.createdAt)
            let title = escape(expense.title)
            let amount = "\(expense.amount)"
            rows.append("\(date),\(title),\(amount),\(expense.currency.code)")
        }
        return rows.joined(separator: "\n")
    }

    private func escape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }

    private func pdf(for expenses: [Expense], range: DateInterval) -> Data {
        #if canImport(UIKit)
        let pageSize = CGSize(width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { context in
            context.beginPage()
            let title = "Expenses"
            title.draw(at: CGPoint(x: 36, y: 36), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24)])

            let rangeString = "\(range.start.formatted(date: .abbreviated, time: .omitted)) — \(range.end.formatted(date: .abbreviated, time: .omitted))"
            rangeString.draw(at: CGPoint(x: 36, y: 72), withAttributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.darkGray])

            var y: CGFloat = 110
            let lineHeight: CGFloat = 20
            let bodyFont = UIFont.systemFont(ofSize: 12)

            let totalsByCurrency = Dictionary(grouping: expenses, by: { $0.currency.code })
                .mapValues { $0.reduce(Decimal(0)) { $0 + $1.amount } }

            "Totals:".draw(at: CGPoint(x: 36, y: y), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            y += lineHeight
            for (code, total) in totalsByCurrency.sorted(by: { $0.key < $1.key }) {
                let line = "\(code): \(total)"
                line.draw(at: CGPoint(x: 48, y: y), withAttributes: [.font: bodyFont])
                y += lineHeight
            }

            y += lineHeight
            "Entries:".draw(at: CGPoint(x: 36, y: y), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            y += lineHeight

            for expense in expenses {
                if y > pageSize.height - 48 {
                    context.beginPage()
                    y = 48
                }
                let date = expense.createdAt.formatted(date: .abbreviated, time: .omitted)
                let line = "\(date)  \(expense.title) — \(expense.amount) \(expense.currency.code)"
                line.draw(at: CGPoint(x: 36, y: y), withAttributes: [.font: bodyFont])
                y += lineHeight
            }
        }
        #else
        return Data()
        #endif
    }
}
