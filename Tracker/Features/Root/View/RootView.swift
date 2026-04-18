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
            compactLayout
        }
    }

    private var compactLayout: some View {
        TabView {
            AddExpenseView(viewModel: container.makeAddExpenseViewModel())
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }

            ExpenseListView(viewModel: container.makeExpenseListViewModel())
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }

            AnalyticsView(viewModel: container.makeAnalyticsViewModel())
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie.fill")
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
            ExpenseListView(viewModel: container.makeExpenseListViewModel())
        case .analytics:
            AnalyticsView(viewModel: container.makeAnalyticsViewModel())
        case .budgets:
            BudgetsView(viewModel: container.makeBudgetsViewModel())
        case .recurring:
            RecurringExpensesView(viewModel: container.makeRecurringExpensesViewModel())
        case .upcoming:
            UpcomingChargesCalendarView(viewModel: container.makeUpcomingChargesCalendarViewModel())
        case .export:
            ExportView(viewModel: container.makeExportViewModel())
        case .settings:
            ComingSoonView(title: "Settings", systemImage: "gearshape")
        }
    }
}
