//
//  AppLockPreferencesStore.swift
//  Tracker
//

import Foundation

nonisolated protocol AppLockPreferencesStore: Sendable {
    var isBiometricLockEnabled: Bool { get set }
}

nonisolated final class UserDefaultsAppLockPreferencesStore: AppLockPreferencesStore {
    private let defaults: UserDefaults
    private let key = "security.biometricLockEnabled"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isBiometricLockEnabled: Bool {
        get { defaults.bool(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }
}
