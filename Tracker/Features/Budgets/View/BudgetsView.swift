//
//  BudgetsView.swift
//  Tracker
//

import SwiftUI

struct BudgetsView: View {
    @StateObject private var viewModel: BudgetsViewModel
    @State private var isAddingBudget = false

    init(viewModel: @autoclosure @escaping () -> BudgetsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Budgets")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            isAddingBudget = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isAddingBudget) {
                    NewBudgetView { draft in
                        Task { await viewModel.add(draft) }
                    }
                }
        }
        .task {
            await viewModel.requestNotificationAccess()
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success(let items) where items.isEmpty:
            emptyState
        case .success(let items):
            List {
                ForEach(items) { budget in
                    BudgetRow(budget: budget)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let budget = items[index]
                        Task { await viewModel.delete(id: budget.id) }
                    }
                }
            }
            .listStyle(.plain)
        case .failure(let message):
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No budgets yet")
                .font(.headline)
            Text("Tap + to set a spending limit.")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct BudgetRow: View {
    let budget: Budget

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(budget.categoryKey.capitalized)
                    .font(.body.weight(.medium))
                Text(budget.period.displayName)
                    .font(.footnote)
                    .foregroundStyle(Theme.Palette.subtleText)
            }
            Spacer()
            Text(budget.limit.formatted(.currency(code: budget.currency.code).locale(.current)))
                .font(.headline.monospacedDigit())
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}
