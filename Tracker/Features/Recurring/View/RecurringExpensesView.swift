//
//  RecurringExpensesView.swift
//  Tracker
//

import SwiftUI

struct RecurringExpensesView: View {
    @StateObject private var viewModel: RecurringExpensesViewModel
    @State private var isAdding = false

    init(viewModel: @autoclosure @escaping () -> RecurringExpensesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Recurring")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button { isAdding = true } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isAdding) {
                    NewRecurringExpenseView { draft in
                        Task { await viewModel.add(draft) }
                    }
                }
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success(let items) where items.isEmpty:
            VStack(spacing: Theme.Spacing.m) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("No subscriptions yet")
                    .font(.headline)
                Text("Add a recurring expense to track subscriptions.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.subtleText)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success(let items):
            List {
                ForEach(items) { item in
                    RecurringRow(item: item)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        Task { await viewModel.delete(id: items[index].id) }
                    }
                }
            }
            .listStyle(.plain)
        case .error(let message):
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct RecurringRow: View {
    let item: RecurringExpense

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(Theme.Palette.accent)
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(item.title).font(.body.weight(.medium))
                Text("\(item.frequency.displayName) · next \(item.nextDate, format: .dateTime.day().month())")
                    .font(.footnote)
                    .foregroundStyle(Theme.Palette.subtleText)
            }
            Spacer()
            Text(item.amount.formatted(.currency(code: item.currency.code).locale(.current)))
                .font(.headline.monospacedDigit())
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}
