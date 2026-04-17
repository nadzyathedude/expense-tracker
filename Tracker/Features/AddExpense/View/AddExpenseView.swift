import SwiftUI

struct AddExpenseView: View {
    @StateObject private var viewModel: AddExpenseViewModel
    @State private var showSuccess: Bool = false
    @FocusState private var focus: Field?

    private enum Field {
        case amount
        case title
    }

    init(viewModel: @autoclosure @escaping () -> AddExpenseViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Palette.background.ignoresSafeArea()

            ScrollView {
                content
            }

            if showSuccess {
                SuccessOverlay()
                    .padding(.top, Theme.Spacing.md)
            }
        }
        .onChange(of: viewModel.event) { _, event in
            handle(event: event)
        }
        .task {
            focus = .amount
        }
        .accessibilityIdentifier("AddExpenseScreen")
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            header
            heroBlock
            TitleField(text: $viewModel.title)
                .focused($focus, equals: .title)
                .accessibilityIdentifier("TitleField")

            categorySection
            dateSection

            submitButton
                .padding(.top, Theme.Spacing.md)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.xl)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("New Expense")
                .font(Theme.Typography.title)
            Text("Log your spending in seconds")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
        }
    }

    private var heroBlock: some View {
        VStack(spacing: Theme.Spacing.md) {
            AmountHeroField(amount: $viewModel.amountText, symbol: viewModel.currency.symbol)
                .focused($focus, equals: .amount)
                .accessibilityIdentifier("AmountField")
            CurrencyChip(selection: $viewModel.currency, currencies: viewModel.availableCurrencies)
                .accessibilityIdentifier("CurrencyChip")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
        .padding(.horizontal, Theme.Spacing.lg)
        .background(Theme.Palette.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("CATEGORY")
                .font(Theme.Typography.label)
                .foregroundStyle(Theme.Palette.subtleText)
            CategoryPicker(
                selection: $viewModel.category,
                categories: viewModel.availableCategories
            )
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("DATE")
                .font(Theme.Typography.label)
                .foregroundStyle(Theme.Palette.subtleText)
            DatePicker(
                "Date",
                selection: $viewModel.date,
                displayedComponents: .date
            )
            .labelsHidden()
            .accessibilityIdentifier("DatePicker")
        }
    }

    private var submitButton: some View {
        PrimaryButton(
            title: "Add Expense",
            isLoading: viewModel.state.isLoading,
            isEnabled: viewModel.canSubmit
        ) {
            focus = nil
            Task {
                await viewModel.submit()
            }
        }
        .accessibilityIdentifier("AddExpenseButton")
    }

    private func handle(event: AddExpenseEvent?) {
        guard let event else {
            return
        }
        switch event {
        case .added:
            showSuccessThenHide()
        case .failed:
            break
        }
    }

    private func showSuccessThenHide() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            showSuccess = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1600))
            withAnimation(.easeOut(duration: 0.25)) {
                showSuccess = false
            }
        }
    }
}

#Preview {
    AddExpenseView(
        viewModel: AddExpenseViewModel(
            repository: DefaultExpenseRepository(dataSource: InMemoryExpenseDataSource())
        )
    )
}
