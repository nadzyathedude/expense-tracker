import SwiftUI

struct BudgetProgressBar: View {
    let progress: Double
    let isOver: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.Palette.surface)
                Capsule()
                    .fill(isOver ? Color.red : Theme.Palette.success)
                    .frame(width: max(4, proxy.size.width * progress))
            }
        }
        .frame(height: 8)
    }
}
