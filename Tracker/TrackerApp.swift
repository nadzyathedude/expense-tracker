//
//  TrackerApp.swift
//  Tracker
//
//  Created by nadzya on 17.04.2026.
//

import SwiftUI
import Combine

@main
struct TrackerApp: App {
    @StateObject private var container = AppContainerHolder()

    var body: some Scene {
        WindowGroup {
            ContentView(container: container.value)
        }
    }
}

@MainActor
final class AppContainerHolder: ObservableObject {
    let value = AppContainer()
}
