//
//  ScanReceiptView.swift
//  Tracker
//

import SwiftUI

struct ScanReceiptView: View {
    let onImport: (ParsedReceipt) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var parsed: ParsedReceipt?
    @State private var isScanning = true

    private let parser = ReceiptParser()

    var body: some View {
        NavigationStack {
            Group {
                if !ReceiptScannerView.isSupported {
                    unavailableState
                } else if isScanning {
                    ReceiptScannerView(
                        onFinish: { lines in
                            parsed = parser.parse(lines: lines)
                            isScanning = false
                        },
                        onCancel: { isScanning = false }
                    )
                    .ignoresSafeArea()
                } else if let result = parsed {
                    resultForm(result)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Scan receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if !isScanning && parsed != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Use") {
                            if let result = parsed { onImport(result) }
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func resultForm(_ receipt: ParsedReceipt) -> some View {
        Form {
            Section("Detected") {
                row(label: "Merchant", value: receipt.merchant ?? "—")
                row(label: "Amount", value: receipt.amount.map { "\($0)" } ?? "—")
                row(label: "Date", value: receipt.date.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "—")
            }
            Section {
                Button("Scan again") {
                    parsed = nil
                    isScanning = true
                }
            }
        }
    }

    private var unavailableState: some View {
        VStack(spacing: Theme.Spacing.m) {
            Image(systemName: "camera.viewfinder")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Scanner unavailable")
                .font(.headline)
            Text("This device doesn't support on-device text scanning.")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.m) {
            Text("No text captured")
                .font(.headline)
            Button("Try again") {
                isScanning = true
            }
        }
        .padding()
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(Theme.Palette.subtleText)
            Spacer()
            Text(value)
        }
    }
}
