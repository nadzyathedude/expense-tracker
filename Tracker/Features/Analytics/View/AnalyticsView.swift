//
//  AnalyticsView.swift
//  Tracker
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel: AnalyticsViewModel

    init(viewModel: @autoclosure @escaping () -> AnalyticsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                    currencyPicker
                    content
                }
                .padding(Theme.Spacing.l)
            }
            .navigationTitle("Analytics")
        }
        .task { await viewModel.load() }
    }

    private var currencyPicker: some View {
        HStack {
            Text("Currency")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.Palette.subtleText)
            Spacer()
            Picker("Currency", selection: $viewModel.selectedCurrency) {
                ForEach(viewModel.availableCurrencies) { currency in
                    Text(currency.code).tag(currency)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.selectedCurrency) { _, _ in
                Task { await viewModel.load() }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity)
        case .success(let summary):
            totalsSection(summary)
            trendSection(summary)
            currencyShareSection(summary)
        case .error(let message):
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func totalsSection(_ summary: SpendingSummary) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            sectionTitle("Totals")
            HStack(spacing: Theme.Spacing.m) {
                totalCard("Today", amount: summary.today)
                totalCard("Week", amount: summary.thisWeek)
                totalCard("Month", amount: summary.thisMonth)
            }
        }
    }

    private func totalCard(_ title: LocalizedStringKey, amount: Decimal) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Theme.Palette.subtleText)
            Text(amount.formatted(.currency(code: viewModel.selectedCurrency.code).locale(.current)))
                .font(.headline.monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.m)
        .background(Theme.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
    }

    private func trendSection(_ summary: SpendingSummary) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            sectionTitle("Trend (30 days)")
            Chart(summary.daily) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Amount", NSDecimalNumber(decimal: point.total).doubleValue)
                )
                .interpolationMethod(.monotone)
            }
            .frame(height: 180)
            .chartYAxis { AxisMarks(position: .leading) }
        }
    }

    private func currencyShareSection(_ summary: SpendingSummary) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            sectionTitle("By currency")
            if summary.byCurrency.isEmpty {
                Text("No data yet")
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.subtleText)
            } else {
                Chart(summary.byCurrency) { item in
                    SectorMark(
                        angle: .value("Total", NSDecimalNumber(decimal: item.total).doubleValue),
                        innerRadius: .ratio(0.5),
                        angularInset: 1
                    )
                    .foregroundStyle(by: .value("Currency", item.currencyCode))
                }
                .frame(height: 220)
            }
        }
    }

    private func sectionTitle(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
    }
}
