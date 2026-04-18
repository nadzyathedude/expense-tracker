//
//  DismissedSuggestionsStore.swift
//  Tracker
//

import Foundation

nonisolated protocol DismissedSuggestionsStore: Sendable {
    func load() -> Set<String>
    func dismiss(id: String)
}

nonisolated final class UserDefaultsDismissedSuggestionsStore: DismissedSuggestionsStore {
    private let defaults: UserDefaults
    private let key = "recurring.dismissedSuggestions"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> Set<String> {
        Set(defaults.array(forKey: key) as? [String] ?? [])
    }

    func dismiss(id: String) {
        var current = load()
        current.insert(id)
        defaults.set(Array(current), forKey: key)
    }
}
