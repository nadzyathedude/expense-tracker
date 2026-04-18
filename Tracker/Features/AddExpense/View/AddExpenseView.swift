//
//  AddExpenseView.swift
//  Tracker
//

import SwiftUI

struct AddExpenseView: View {
    @StateObject private var viewModel: AddExpenseViewModel
    @State private var showSuccess = false
    @FocusState private var focusedField: Field?

    private enum Field { case title, amount }

    init(viewModel: @autoclosure @escaping () -> AddExpenseViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Palette.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                header

                VStack(spacing: Theme.Spacing.l) {
                    InputField(
                        label: "Title",
                        placeholder: "e.g. Groceries, Coffee",
                        text: $viewModel.title
                    )
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .amount }

                    InputField(
                        label: "Amount",
                        placeholder: "0.00",
                        text: $viewModel.amountText,
                        keyboard: .decimalPad
                    ) {
                        CurrencyPicker(
                            selection: $viewModel.currency,
                            currencies: viewModel.availableCurrencies
                        )
                    }
                    .focused($focusedField, equals: .amount)

                    VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                        Text("Category")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.Palette.subtleText)
                        CategoryPicker(
                            selection: $viewModel.category,
                            categories: viewModel.availableCategories
                        )
                    }
                }

                Spacer(minLength: 0)

                PrimaryButton(
                    title: "Add Expense",
                    isLoading: viewModel.state.isLoading,
                    isEnabled: viewModel.isSubmitEnabled
                ) {
                    Task {
                        focusedField = nil
                        await viewModel.addExpense()
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.l)
            .padding(.vertical, Theme.Spacing.xl)

            if showSuccess {
                SuccessToast(message: "Expense added")
                    .padding(.top, Theme.Spacing.m)
            }
        }
        .onChange(of: viewModel.event) { _, event in
            handle(event: event)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("New Expense")
                .font(.largeTitle.weight(.bold))
            Text("Log your spending in seconds")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
        }
    }

    private func handle(event: AddExpenseEvent?) {
        guard let event else { return }
        switch event {
        case .expenseAdded:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                showSuccess = true
            }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                withAnimation(.easeOut(duration: 0.25)) {
                    showSuccess = false
                }
            }
        case .showError:
            break
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
