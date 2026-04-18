//
//  BudgetsViewModel.swift
//  Tracker
//

import Foundation
import Combine

@MainActor
final class BudgetsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[Budget]> = .idle
    @Published var notificationsEnabled: Bool = false

    private let repository: BudgetRepository
    private let notifications: NotificationService

    init(repository: BudgetRepository, notifications: NotificationService) {
        self.repository = repository
        self.notifications = notifications
    }

    func load() async {
        state = .loading
        do {
            let items = try await repository.fetchAll()
            state = .success(items)
        } catch {
            state = .failure("Couldn't load budgets.")
        }
    }

    func requestNotificationAccess() async {
        notificationsEnabled = await notifications.requestAuthorization()
    }

    func add(_ budget: Budget) async {
        do {
            try await repository.add(budget)
            await load()
        } catch {
            state = .failure("Couldn't save budget.")
        }
    }

    func delete(id: UUID) async {
        do {
            try await repository.delete(id: id)
            await notifications.cancel(id: id.uuidString)
            await load()
        } catch {
            state = .failure("Couldn't delete budget.")
        }
    }
}
