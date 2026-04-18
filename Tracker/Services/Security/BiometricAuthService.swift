//
//  BiometricAuthService.swift
//  Tracker
//

import Foundation
import LocalAuthentication

nonisolated enum BiometricAuthError: Error {
    case unavailable
    case cancelled
    case failed(String)
}

nonisolated protocol BiometricAuthService: Sendable {
    var isAvailable: Bool { get }
    func authenticate(reason: String) async throws
}

nonisolated final class LocalAuthBiometricService: BiometricAuthService {
    var isAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    func authenticate(reason: String) async throws {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            throw BiometricAuthError.unavailable
        }
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            if !success {
                throw BiometricAuthError.failed("Authentication failed.")
            }
        } catch let error as LAError where error.code == .userCancel || error.code == .systemCancel || error.code == .appCancel {
            throw BiometricAuthError.cancelled
        } catch {
            throw BiometricAuthError.failed(error.localizedDescription)
        }
    }
}
