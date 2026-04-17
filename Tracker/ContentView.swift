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
        AddExpenseView(viewModel: container.makeAddExpenseViewModel())
    }
}

#Preview {
    ContentView(container: AppContainer())
}
