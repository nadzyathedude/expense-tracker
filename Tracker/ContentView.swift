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

            UpcomingChargesCalendarView(viewModel: container.makeUpcomingChargesCalendarViewModel())
                .tabItem {
                    Label("Upcoming", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    ContentView(container: AppContainer())
}
