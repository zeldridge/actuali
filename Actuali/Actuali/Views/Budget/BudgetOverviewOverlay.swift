import SwiftUI

/// The compact month overview stays over the budget so it can be checked and
/// dismissed without losing the user's place in the table.
struct BudgetOverviewOverlay: View {
    @Environment(\.locale) private var locale

    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.32)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 16) {
                HStack {
                    Label(String(localized: "Budget Overview", locale: locale), systemImage: "chart.pie.fill")
                        .font(.title3.weight(.semibold))

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(.thinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(String(localized: "Close", locale: locale)))
                    .accessibilityIdentifier("budget.overview.close")
                }

                overviewSection(
                    title: String(localized: "Next Month Coverage", locale: locale),
                    icon: "gauge.with.dots.needle.33percent"
                )
                overviewSection(
                    title: String(localized: "Scheduled Transactions", locale: locale),
                    icon: "calendar.badge.clock"
                )
            }
            .padding(20)
            .frame(maxWidth: 430)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
            .padding(.horizontal, 16)
            .safeAreaPadding(.top, 8)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("budget.overview.card")
        }
    }

    private func overviewSection(title: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline)

            RoundedRectangle(cornerRadius: 3)
                .fill(.tertiary)
                .frame(width: 96, height: 6)
            RoundedRectangle(cornerRadius: 3)
                .fill(.quaternary)
                .frame(height: 6)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

#Preview {
    BudgetOverviewOverlay(onDismiss: {})
}
