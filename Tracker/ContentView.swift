//
//  ContentView.swift
//  Tracker
//
//  Created by nadzya on 17.04.2026.
//

import SwiftUI

struct ContentView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            AddExpenseView(viewModel: container.makeAddExpenseViewModel())
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }

            AnalyticsView(viewModel: container.makeAnalyticsViewModel())
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie.fill")
                }
        }
    }
}

#Preview {
    ContentView(container: AppContainer())
}
