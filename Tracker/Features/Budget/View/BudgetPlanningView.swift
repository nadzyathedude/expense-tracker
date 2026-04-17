import SwiftUI

struct BudgetPlanningView: View {
    @StateObject private var viewModel: BudgetPlanningViewModel
    @State private var sheet: SheetTarget?

    private enum SheetTarget: Identifiable {
        case overall
        case category(ExpenseCategory)

        var id: String {
            switch self {
            case .overall:
                return "overall"
            case let .category(category):
                return category.id
            }
        }
    }

    init(viewModel: @autoclosure @escaping () -> BudgetPlanningViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            Theme.Palette.background.ignoresSafeArea()
            content
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.currency) { _, _ in
            Task { await viewModel.load() }
        }
        .sheet(item: $sheet) { target in
            sheetView(for: target)
        }
        .accessibilityIdentifier("BudgetScreen")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case let .success(summary):
            loaded(summary: summary)
        case let .failure(message):
            VStack(spacing: Theme.Spacing.md) {
                Text(message)
                    .foregroundStyle(.secondary)
                Button("Retry") {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    private func loaded(summary: BudgetSummary) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                MonthSwitcher(
                    yearMonth: summary.yearMonth,
                    onPrevious: { Task { await viewModel.moveMonth(by: -1) } },
                    onNext: { Task { await viewModel.moveMonth(by: 1) } }
                )

                currencyRow

                BudgetSummaryCard(summary: summary)

                Button {
                    sheet = .overall
                } label: {
                    Label(
                        summary.overallBudget == nil ? "Set overall budget" : "Edit overall budget",
                        systemImage: summary.overallBudget == nil ? "plus.circle.fill" : "pencil.circle.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.Palette.accent)
                }
                .accessibilityIdentifier("EditOverallBudgetButton")

                Text("Categories")
                    .font(Theme.Typography.label)
                    .foregroundStyle(Theme.Palette.subtleText)
                    .padding(.top, Theme.Spacing.sm)

                VStack(spacing: 0) {
                    ForEach(summary.categoryBreakdowns) { breakdown in
                        CategoryBudgetRow(
                            breakdown: breakdown,
                            currency: summary.currency,
                            onEdit: { sheet = .category(breakdown.category) }
                        )
                        Divider()
                    }
                }
            }
            .padding(Theme.Spacing.lg)
        }
    }

    private var currencyRow: some View {
        HStack {
            Text("CURRENCY")
                .font(Theme.Typography.label)
                .foregroundStyle(Theme.Palette.subtleText)
            Spacer()
            CurrencyChip(
                selection: $viewModel.currency,
                currencies: viewModel.availableCurrencies
            )
            .accessibilityIdentifier("BudgetCurrencyChip")
        }
    }

    private func sheetView(for target: SheetTarget) -> some View {
        let summary = currentSummary
        switch target {
        case .overall:
            return AnyView(
                SetBudgetSheet(
                    title: "Overall budget",
                    currency: viewModel.currency,
                    existingAmount: summary?.overallBudget
                ) { amount in
                    Task { await viewModel.setBudget(amount: amount, category: nil) }
                }
            )
        case let .category(category):
            let existing = summary?.categoryBreakdowns.first { $0.category == category }?.budget
            return AnyView(
                SetBudgetSheet(
                    title: category.name,
                    currency: viewModel.currency,
                    existingAmount: existing
                ) { amount in
                    Task { await viewModel.setBudget(amount: amount, category: category) }
                }
            )
        }
    }

    private var currentSummary: BudgetSummary? {
        if case let .success(summary) = viewModel.state {
            return summary
        }
        return nil
    }
}

#Preview {
    let expenseRepo = DefaultExpenseRepository(dataSource: InMemoryExpenseDataSource())
    let budgetRepo = DefaultBudgetRepository(dataSource: InMemoryBudgetDataSource())
    let summary = DefaultGetMonthlyBudgetSummaryUseCase(
        expenseRepository: expenseRepo,
        budgetRepository: budgetRepo
    )
    let setBudget = DefaultSetMonthlyBudgetUseCase(repository: budgetRepo)
    return BudgetPlanningView(
        viewModel: BudgetPlanningViewModel(
            summaryUseCase: summary,
            setBudgetUseCase: setBudget
        )
    )
}
