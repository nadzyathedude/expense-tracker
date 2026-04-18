import SwiftUI

struct ContentView: View {
    let container: AppContainer
    @State private var selection: Tab = .add

    private enum Tab: Hashable {
        case add
        case budget
    }

    var body: some View {
        TabView(selection: $selection) {
            AddExpenseView(viewModel: container.makeAddExpenseViewModel())
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(Tab.add)
                .accessibilityIdentifier("AddExpenseTab")

            BudgetPlanningView(viewModel: container.makeBudgetPlanningViewModel())
                .tabItem {
                    Label("Budget", systemImage: "chart.pie.fill")
                }
                .tag(Tab.budget)
                .accessibilityIdentifier("BudgetTab")
        }
    }
}

#Preview {
    ContentView(container: AppContainer())
}
