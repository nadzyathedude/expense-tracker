//
//  NotificationService.swift
//  Tracker
//

import Foundation
import UserNotifications

protocol NotificationService {
    func requestAuthorization() async -> Bool
    func scheduleBudgetThreshold(id: String, title: String, body: String) async throws
    func cancel(id: String) async
}

struct LocalNotificationService: NotificationService {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleBudgetThreshold(id: String, title: String, body: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    func cancel(id: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
}
