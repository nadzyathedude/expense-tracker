//
//  RecurringSuggestionsView.swift
//  Tracker
//

import SwiftUI

struct RecurringSuggestionsView: View {
    @StateObject private var viewModel: RecurringSuggestionsViewModel
    let onAccept: (RecurringCandidate) -> Void

    init(
        viewModel: @autoclosure @escaping () -> RecurringSuggestionsViewModel,
        onAccept: @escaping (RecurringCandidate) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onAccept = onAccept
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Suggestions")
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success(let items) where items.isEmpty:
            empty
        case .success(let items):
            List(items) { candidate in
                CandidateRow(
                    candidate: candidate,
                    onAccept: { onAccept(candidate) },
                    onDismiss: { Task { await viewModel.dismiss(candidate) } }
                )
            }
            .listStyle(.plain)
        case .failure(let message):
            Text(message).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var empty: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No recurring charges detected")
                .font(.headline)
            Text("Add more expenses and we'll flag likely subscriptions.")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct CandidateRow: View {
    let candidate: RecurringCandidate
    let onAccept: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text(candidate.title)
                    .font(.body.weight(.medium))
                Spacer()
                Text(candidate.averageAmount.formatted(.currency(code: candidate.currencyCode).locale(.current)))
                    .font(.headline.monospacedDigit())
            }
            Text("Every ~\(candidate.intervalDays) days · \(candidate.occurrences) charges")
                .font(.footnote)
                .foregroundStyle(Theme.Palette.subtleText)
            HStack {
                Button("Ignore", role: .destructive) { onDismiss() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Add as recurring") { onAccept() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}
