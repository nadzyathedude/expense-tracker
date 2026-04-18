//
//  RootView.swift
//  Tracker
//

import SwiftUI

struct RootView: View {
    let container: AppContainer
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selection: SidebarDestination = .add

    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                sidebar
            } detail: {
                detail(for: selection)
                    .navigationTitle(Text(selection.title))
                    .frame(maxWidth: 720, maxHeight: .infinity, alignment: .top)
            }
        } else {
            NavigationStack {
                detail(for: .add)
            }
        }
    }

    private var sidebar: some View {
        List {
            ForEach(SidebarDestination.allCases) { destination in
                Button {
                    selection = destination
                } label: {
                    Label(destination.title, systemImage: destination.systemImage)
                        .foregroundStyle(destination == selection ? Theme.Palette.accent : Color.primary)
                }
                .listRowBackground(destination == selection ? Theme.Palette.accent.opacity(0.1) : Color.clear)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Tracker")
    }

    @ViewBuilder
    private func detail(for destination: SidebarDestination) -> some View {
        switch destination {
        case .add:
            AddExpenseView(viewModel: container.makeAddExpenseViewModel())
        case .list:
            ComingSoonView(title: "Expense List", systemImage: "list.bullet")
        case .analytics:
            ComingSoonView(title: "Analytics", systemImage: "chart.pie")
        case .budgets:
            ComingSoonView(title: "Budgets", systemImage: "chart.bar.doc.horizontal")
        case .recurring:
            ComingSoonView(title: "Recurring", systemImage: "arrow.triangle.2.circlepath")
        case .settings:
            ComingSoonView(title: "Settings", systemImage: "gearshape")
        }
    }
}
