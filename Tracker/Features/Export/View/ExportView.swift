//
//  ExportView.swift
//  Tracker
//

import SwiftUI

struct ExportView: View {
    @StateObject private var viewModel: ExportViewModel

    init(viewModel: @autoclosure @escaping () -> ExportViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Date range") {
                    DatePicker("From", selection: $viewModel.startDate, displayedComponents: .date)
                    DatePicker("To", selection: $viewModel.endDate, displayedComponents: .date)
                }

                Section("Format") {
                    Picker("Format", selection: $viewModel.format) {
                        ForEach(ExportFormat.allCases) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button {
                        Task { await viewModel.export() }
                    } label: {
                        if viewModel.state.isLoading {
                            HStack {
                                ProgressView()
                                Text("Preparing…")
                            }
                        } else {
                            Text("Generate export")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.state.isLoading)
                }

                resultSection
            }
            .navigationTitle("Export")
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        switch viewModel.state {
        case .success(let file):
            Section("Result") {
                ShareLink(item: file.url) {
                    Label("Share \(file.format.displayName)", systemImage: "square.and.arrow.up")
                }
            }
        case .error(let message):
            Section {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        default:
            EmptyView()
        }
    }
}
