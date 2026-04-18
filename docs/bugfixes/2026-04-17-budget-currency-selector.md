# Bugfix: Budget screen is missing a currency selector

**Date:** 2026-04-17
**Severity:** Functional gap (user cannot change currency for monthly overall budget)
**Reporter:** User via `/bugfix`
**Scope:** `Tracker/Features/Budget/View/BudgetPlanningView.swift`

---

## Symptoms

On the **Budget** tab, users can:

- Switch months with `MonthSwitcher`
- Set an overall budget for the currently displayed currency
- Set per-category budgets

…but they have **no control to change the currency** of the monthly overall budget. The currency is silently locked to `.usd` (the default on `BudgetPlanningViewModel.init`) for the entire session.

## Root Cause

`BudgetPlanningViewModel` was already currency-aware end-to-end:

- `@Published var currency: Currency = .usd`
- `let availableCurrencies: [Currency] = Currency.all`
- `func setCurrency(_:) async` (reloads after mutation)
- `GetMonthlyBudgetSummaryUseCase` filters expenses and budgets by the selected currency
- `SetBudgetSheet` already reads `viewModel.currency` to label and persist the budget's currency

**However**, `BudgetPlanningView` never rendered any UI control that exposed this. The user was shut out of the entire currency-switching flow despite the backing logic being correct.

Classification: **missing UI surface**, not a logic defect.

## Fix

All changes confined to `Tracker/Features/Budget/View/BudgetPlanningView.swift`.

1. Added a `currencyRow` computed view that shows a label and a `CurrencyChip` bound to `$viewModel.currency`:

   ```swift
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
   ```

2. Inserted `currencyRow` between `MonthSwitcher` and `BudgetSummaryCard` in `loaded(summary:)`.

3. Added an `.onChange(of: viewModel.currency)` modifier on the view's root that calls `viewModel.load()`, so the summary + category breakdowns recompute against the newly picked currency:

   ```swift
   .onChange(of: viewModel.currency) { _, _ in
       Task { await viewModel.load() }
   }
   ```

### What was deliberately NOT changed

- No changes to `BudgetPlanningViewModel`, use-cases, repositories, or the data source. The VM's `setCurrency(_:)` method still exists for programmatic use; the view uses the two-way binding + `onChange` for a more idiomatic SwiftUI flow.
- No new component — reused the existing `CurrencyChip` from the AddExpense feature for visual consistency.
- No navigation, persistence, or model changes.

## Verification

### Build

```bash
xcodebuild -project Tracker.xcodeproj -scheme Tracker \
  -destination 'generic/platform=iOS Simulator' build
```

Result: **BUILD SUCCEEDED**.

### Manual flow (to run in Xcode)

1. Launch app → tap **Budget** tab.
2. Expect: new **CURRENCY** row beneath the month switcher, chip shows `USD`.
3. Tap the chip → pick `EUR` → chip updates; summary reloads to EUR-scoped totals.
4. Tap **Set overall budget** → `SetBudgetSheet` header reads "Set a monthly cap in EUR".
5. Save amount → return to Budget screen → summary shows the EUR budget and EUR-denominated spend.
6. Switch back to `USD` → previous USD budget reappears, EUR budget is filtered out.

### Regression surface checked

| Concern | Result |
|---|---|
| Category sheet still receives correct currency | ✓ `sheetView(for:)` reads `viewModel.currency` at sheet build time |
| Month switch after currency change | ✓ `moveMonth` calls `load()`; uses current `currency` |
| Rapid currency toggling | ✓ `load()` resets `state = .loading`; each execution captures `currency` at call time — no TOCTOU; no data race |
| Loading / failure states | ✓ `onChange` fires `load()` regardless of prior state |
| AccessibilityID stability | ✓ New element has stable static identifier `BudgetCurrencyChip` |

## Edge Cases Considered

- **Currency with zero data**: `GetMonthlyBudgetSummaryUseCase` returns `overallBudget == nil` and `totalSpent == 0`; existing empty-state copy ("No overall budget set") renders correctly.
- **Concurrency**: `.onChange` handler wraps the reload in `Task { … }`; `BudgetPlanningViewModel` is `@MainActor`, so no isolation violations.
- **Binding freshness**: `@Published` + `@StateObject` ensures the bound `Currency` is always the current VM value — no stale captures.

## CLAUDE.md Compliance

- ✅ View stays declarative — no business logic added
- ✅ No force unwraps, no `print()`
- ✅ Uses `async/await`; `ViewModel` runs on `@MainActor`
- ✅ New interactive element has `AccessibilityIdentifier` per *UI Smoke Scenarios* rules
- ✅ Minimal fix per *Auto-Fix Loop* scope: only a `View` binding was touched, within allowed fix types
