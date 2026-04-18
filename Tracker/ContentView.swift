//
//  ContentView.swift
//  Tracker
//
//  Created by nadzya on 17.04.2026.
//

import SwiftUI

struct ContentView: View {
    let container: AppContainer
    @StateObject private var settingsViewModel: SettingsViewModel
    @State private var isSettingsPresented = false

    init(container: AppContainer) {
        self.container = container
        _settingsViewModel = StateObject(wrappedValue: container.makeSettingsViewModel())
    }

    var body: some View {
        TabView {
            AddExpenseView(viewModel: container.makeAddExpenseViewModel())
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }

            ExpenseListView(viewModel: container.makeExpenseListViewModel())
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }

            RecurringExpensesView(viewModel: container.makeRecurringExpensesViewModel())
                .tabItem {
                    Label("Recurring", systemImage: "arrow.triangle.2.circlepath")
                }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                isSettingsPresented = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(Theme.Palette.subtleText)
                    .padding(Theme.Spacing.md)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel(Text("Settings"))
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(viewModel: settingsViewModel)
        }
        .preferredColorScheme(settingsViewModel.theme.colorScheme)
    }
}

#Preview {
    ContentView(container: AppContainer())
}
