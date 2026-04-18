//
//  SidebarDestination.swift
//  Tracker
//

import SwiftUI

enum SidebarDestination: String, CaseIterable, Identifiable, Hashable {
    case add
    case list
    case analytics
    case budgets
    case recurring
    case upcoming
    case export
    case suggestions
    case settings

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .add: return "Add expense"
        case .list: return "List"
        case .analytics: return "Analytics"
        case .budgets: return "Budgets"
        case .recurring: return "Recurring"
        case .upcoming: return "Upcoming"
        case .export: return "Export"
        case .suggestions: return "Suggestions"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .add: return "plus.circle"
        case .list: return "list.bullet"
        case .analytics: return "chart.pie"
        case .budgets: return "chart.bar.doc.horizontal"
        case .recurring: return "arrow.triangle.2.circlepath"
        case .upcoming: return "calendar"
        case .export: return "square.and.arrow.up"
        case .suggestions: return "sparkles"
        case .settings: return "gearshape"
        }
    }
}
