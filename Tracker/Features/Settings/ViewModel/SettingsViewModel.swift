//
//  SettingsViewModel.swift
//  Tracker
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var theme: AppTheme {
        didSet {
            guard theme != oldValue else { return }
            repository.saveTheme(theme)
        }
    }

    private let repository: SettingsRepository

    init(repository: SettingsRepository) {
        self.repository = repository
        self.theme = repository.loadTheme()
    }
}
