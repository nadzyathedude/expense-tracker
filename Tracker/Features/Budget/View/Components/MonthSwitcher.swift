import SwiftUI

struct MonthSwitcher: View {
    let yearMonth: YearMonth
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 32, height: 32)
                    .background(Theme.Palette.surface)
                    .clipShape(Circle())
            }
            .accessibilityIdentifier("PreviousMonthButton")

            Spacer()

            Text(yearMonth.displayString())
                .font(.headline)
                .accessibilityIdentifier("CurrentMonthLabel")

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .frame(width: 32, height: 32)
                    .background(Theme.Palette.surface)
                    .clipShape(Circle())
            }
            .accessibilityIdentifier("NextMonthButton")
        }
        .foregroundStyle(.primary)
    }
}
