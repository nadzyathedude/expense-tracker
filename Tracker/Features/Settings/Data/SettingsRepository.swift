//
//  SettingsRepository.swift
//  Tracker
//

import Foundation

protocol SettingsRepository {
    func loadTheme() -> AppTheme
    func saveTheme(_ theme: AppTheme)
}

final class UserDefaultsSettingsRepository: SettingsRepository {
    private let defaults: UserDefaults
    private let themeKey = "settings.appTheme"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadTheme() -> AppTheme {
        guard let raw = defaults.string(forKey: themeKey),
              let theme = AppTheme(rawValue: raw) else {
            return .system
        }
        return theme
    }

    func saveTheme(_ theme: AppTheme) {
        defaults.set(theme.rawValue, forKey: themeKey)
    }
}
