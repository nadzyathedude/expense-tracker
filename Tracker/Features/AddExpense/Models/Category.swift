//
//  Category.swift
//  Tracker
//

import SwiftUI

struct Category: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let iconName: String
    let tintHex: String

    var color: Color { Color(hex: tintHex) ?? .gray }
}

extension Category {
    static let food = Category(id: "food", name: "Food", iconName: "fork.knife", tintHex: "#F4A261")
    static let transport = Category(id: "transport", name: "Transport", iconName: "car.fill", tintHex: "#2A9D8F")
    static let entertainment = Category(id: "entertainment", name: "Entertainment", iconName: "gamecontroller.fill", tintHex: "#E76F51")
    static let shopping = Category(id: "shopping", name: "Shopping", iconName: "bag.fill", tintHex: "#B388EB")
    static let bills = Category(id: "bills", name: "Bills", iconName: "doc.text.fill", tintHex: "#457B9D")
    static let health = Category(id: "health", name: "Health", iconName: "heart.fill", tintHex: "#E63946")
    static let travel = Category(id: "travel", name: "Travel", iconName: "airplane", tintHex: "#1D3557")
    static let other = Category(id: "other", name: "Other", iconName: "circle.dashed", tintHex: "#8D99AE")

    static let all: [Category] = [
        .food, .transport, .entertainment, .shopping,
        .bills, .health, .travel, .other
    ]
}

extension Color {
    init?(hex: String) {
        let trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard trimmed.count == 6, let value = UInt32(trimmed, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
