//
//  AppLockViewModel.swift
//  Tracker
//

import Foundation
import Combine

enum AppLockState: Equatable {
    case unlocked
    case locked
    case authenticating
    case failed(String)
}

@MainActor
final class AppLockViewModel: ObservableObject {
    @Published private(set) var state: AppLockState = .unlocked
    @Published var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            preferences.isBiometricLockEnabled = isEnabled
            if isEnabled {
                lastBackgroundedAt = Date()
            }
        }
    }

    private let service: BiometricAuthService
    private var preferences: AppLockPreferencesStore
    private var lastBackgroundedAt: Date?
    private let unlockGrace: TimeInterval

    init(
        service: BiometricAuthService,
        preferences: AppLockPreferencesStore,
        unlockGrace: TimeInterval = 30
    ) {
        self.service = service
        self.preferences = preferences
        self.unlockGrace = unlockGrace
        self.isEnabled = preferences.isBiometricLockEnabled
    }

    var isBiometricAvailable: Bool {
        service.isAvailable
    }

    func didEnterBackground() {
        lastBackgroundedAt = Date()
    }

    func didBecomeActive() {
        guard isEnabled else {
            state = .unlocked
            return
        }
        if let last = lastBackgroundedAt, Date().timeIntervalSince(last) < unlockGrace, state == .unlocked {
            return
        }
        state = .locked
    }

    func authenticate() async {
        state = .authenticating
        do {
            try await service.authenticate(reason: "Unlock your expenses")
            state = .unlocked
            lastBackgroundedAt = nil
        } catch BiometricAuthError.cancelled {
            state = .locked
        } catch BiometricAuthError.unavailable {
            state = .failed("Biometric authentication unavailable.")
        } catch BiometricAuthError.failed(let message) {
            state = .failed(message)
        } catch {
            state = .failed("Couldn't authenticate.")
        }
    }
}
