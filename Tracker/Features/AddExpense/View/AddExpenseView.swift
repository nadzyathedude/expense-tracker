import SwiftUI

struct AddExpenseView: View {
    @StateObject private var viewModel: AddExpenseViewModel
    @State private var showSuccess: Bool = false
    @State private var isScanningReceipt = false
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

            content

            if showSuccess {
                SuccessOverlay()
                    .padding(.top, Theme.Spacing.md)
            }
        }
        .onChange(of: viewModel.event) { _, event in
            handle(event: event)
        }
        .sheet(isPresented: $isScanningReceipt) {
            ScanReceiptView { receipt in
                viewModel.apply(receipt)
            }
        }
        .task {
            focus = .amount
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            header
            heroBlock
            TitleField(text: $viewModel.title)
                .focused($focus, equals: .title)
            scanButton
            Spacer(minLength: 0)
            submitButton
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
            CurrencyChip(selection: $viewModel.currency, currencies: viewModel.availableCurrencies)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
        .padding(.horizontal, Theme.Spacing.lg)
        .background(Theme.Palette.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
    }

    private var scanButton: some View {
        Button {
            isScanningReceipt = true
        } label: {
            Label("Scan receipt", systemImage: "doc.viewfinder")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
        }
        .buttonStyle(.bordered)
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
