//
//  UpcomingChargesCalendarView.swift
//  Tracker
//

import SwiftUI

struct UpcomingChargesCalendarView: View {
    @StateObject private var viewModel: UpcomingChargesCalendarViewModel
    @State private var selectedDay: Date?

    private let calendar: Calendar

    init(
        viewModel: @autoclosure @escaping () -> UpcomingChargesCalendarViewModel,
        calendar: Calendar = .current
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.calendar = calendar
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                monthHeader
                forecastSummary
                weekdayHeader
                grid
                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .navigationTitle("Upcoming")
        }
        .task { await viewModel.load() }
        .sheet(item: daySelectionBinding) { selection in
            dayDetail(for: selection.date, charges: selection.charges)
        }
    }

    private var monthHeader: some View {
        HStack {
            Button { viewModel.step(months: -1) } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(viewModel.displayedMonth, format: .dateTime.month(.wide).year())
                .font(.title3.weight(.semibold))
            Spacer()
            Button { viewModel.step(months: 1) } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    private var forecastSummary: some View {
        let totals = viewModel.totalFor(month: viewModel.displayedMonth)
        return VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Expected this month")
                .font(.footnote)
                .foregroundStyle(Theme.Palette.subtleText)
            if totals.isEmpty {
                Text("No scheduled charges")
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.subtleText)
            } else {
                ForEach(totals.sorted(by: { $0.key < $1.key }), id: \.key) { code, total in
                    Text(total.formatted(.currency(code: code).locale(.current)))
                        .font(.headline.monospacedDigit())
                }
            }
        }
    }

    private var weekdayHeader: some View {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return HStack {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.Palette.subtleText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var grid: some View {
        let days = daysInDisplayedMonthGrid()
        let markers = viewModel.chargesByDay
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days, id: \.self) { day in
                if let day {
                    let key = calendar.startOfDay(for: day)
                    Button {
                        selectedDay = key
                    } label: {
                        dayCell(day: day, hasCharges: markers[key]?.isEmpty == false)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
    }

    private func dayCell(day: Date, hasCharges: Bool) -> some View {
        let isToday = calendar.isDateInToday(day)
        return VStack(spacing: 2) {
            Text(day, format: .dateTime.day())
                .font(.body.monospacedDigit())
                .foregroundStyle(isToday ? Color.white : .primary)
            Circle()
                .fill(hasCharges ? Theme.Palette.accent : .clear)
                .frame(width: 6, height: 6)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isToday ? Theme.Palette.accent.opacity(0.9) : Theme.Palette.surface.opacity(0.4))
        )
    }

    private func daysInDisplayedMonthGrid() -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: viewModel.displayedMonth) else {
            return []
        }
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = ((firstWeekday - calendar.firstWeekday) + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        var cursor = firstDay
        while cursor < interval.end {
            days.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }

    private var daySelectionBinding: Binding<DaySelection?> {
        Binding(
            get: {
                guard let day = selectedDay else { return nil }
                let charges = viewModel.chargesByDay[day] ?? []
                return DaySelection(date: day, charges: charges)
            },
            set: { newValue in selectedDay = newValue?.date }
        )
    }

    private func dayDetail(for day: Date, charges: [UpcomingCharge]) -> some View {
        NavigationStack {
            List {
                if charges.isEmpty {
                    Text("No charges expected")
                } else {
                    ForEach(charges) { charge in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(charge.title).font(.body.weight(.medium))
                                Text(charge.date, format: .dateTime.day().month())
                                    .font(.footnote)
                                    .foregroundStyle(Theme.Palette.subtleText)
                            }
                            Spacer()
                            Text(charge.amount.formatted(.currency(code: charge.currencyCode).locale(.current)))
                                .font(.headline.monospacedDigit())
                        }
                    }
                }
            }
            .navigationTitle(day.formatted(date: .abbreviated, time: .omitted))
        }
        .presentationDetents([.medium, .large])
    }
}

private struct DaySelection: Identifiable {
    let date: Date
    let charges: [UpcomingCharge]
    var id: Date { date }
}
