//
//  ExportViewModel.swift
//  Tracker
//

import Foundation
import Combine

@MainActor
final class ExportViewModel: ObservableObject {
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var format: ExportFormat = .csv
    @Published private(set) var state: ViewState<ExportedFile> = .idle

    private let useCase: ExportUseCase

    init(useCase: ExportUseCase, calendar: Calendar = .current) {
        self.useCase = useCase
        let now = Date()
        self.endDate = now
        self.startDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
    }

    func export() async {
        state = .loading
        let range = DateInterval(start: min(startDate, endDate), end: max(startDate, endDate))
        do {
            let file = try await useCase.execute(range: range, format: format)
            state = .success(file)
        } catch {
            state = .failure("Couldn't create export. Please try again.")
        }
    }

    func reset() {
        state = .idle
    }
}
