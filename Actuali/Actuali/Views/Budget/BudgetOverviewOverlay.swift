import SwiftUI

/// The compact month overview stays over the budget so it can be checked and
/// dismissed without losing the user's place in the table.
struct BudgetOverviewOverlay: View {
    private static let maximumVisibleSchedules = 4
    private static let scheduleRowHeight: CGFloat = 76

    @EnvironmentObject private var budgetStore: BudgetStore
    @Environment(\.locale) private var locale
    @State private var pendingDelete: ScheduleSummary?
    @State private var actionError: String?

    let month: String
    let onOpenSchedule: (ScheduleSummary) -> Void
    let onDismiss: () -> Void

    private var schedulesThisMonth: [ScheduleSummary] {
        BudgetOverviewSchedules.forMonth(month, schedules: budgetStore.schedules)
    }

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
                scheduledTransactionsSection(schedulesThisMonth)
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
        .confirmationDialog(
            pendingDelete.map { _ in ReportStrings.text("Delete this schedule?", locale: locale) } ?? "",
            isPresented: Binding(
                get: { pendingDelete != nil },
                set: {
                    if !$0 {
                        pendingDelete = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button(ReportStrings.text("Delete Schedule", locale: locale), role: .destructive) {
                guard let schedule = pendingDelete else { return }
                Task {
                    do { try await budgetStore.deleteSchedule(schedule) }
                    catch { actionError = error.localizedDescription }
                }
            }
        } message: {
            Text(ReportStrings.text("Transactions this schedule already created are kept.", locale: locale))
        }
        .alert(ReportStrings.text("Action Failed", locale: locale), isPresented: Binding(
            get: { actionError != nil },
            set: {
                if !$0 {
                    actionError = nil
                }
            }
        )) {
            Button(ReportStrings.text("OK", locale: locale)) {}
        } message: {
            Text(actionError ?? "")
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

    private func scheduledTransactionsSection(_ schedules: [ScheduleSummary]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(String(localized: "Scheduled Transactions", locale: locale), systemImage: "calendar.badge.clock")
                    .font(.headline)

                Spacer()

                Text(schedules.count, format: .number)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }

            if schedules.isEmpty {
                Text(String(localized: "Nothing scheduled this month", locale: locale))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                List(schedules) { schedule in
                    let status = budgetStore.scheduleStatuses[schedule.id] ?? .scheduled
                    ScheduleListItem(
                        schedule: schedule,
                        status: status,
                        accountName: accountName(schedule),
                        payeeName: payeeName(schedule),
                        statusLabel: relativeDateLabel(schedule, status: status),
                        statusTint: relativeDateTint(status),
                        onSelect: { onOpenSchedule(schedule) },
                        onDelete: { pendingDelete = schedule },
                        onActionError: { actionError = $0 }
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .scrollBounceBehavior(.always)
                .frame(
                    height: CGFloat(min(schedules.count, Self.maximumVisibleSchedules))
                        * Self.scheduleRowHeight
                )
                .environment(\.defaultMinListRowHeight, Self.scheduleRowHeight)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .accessibilityIdentifier("budget.overview.scheduled")
    }

    private func accountName(_ schedule: ScheduleSummary) -> String? {
        schedule.accountId.flatMap { id in
            budgetStore.accounts.first { $0.id == id }?.name
        }
    }

    private func payeeName(_ schedule: ScheduleSummary) -> String? {
        schedule.payeeId.flatMap { id in
            budgetStore.payees.first { $0.id == id }?.name
        }
    }

    private func relativeDateLabel(_ schedule: ScheduleSummary, status: ScheduleStatus) -> String? {
        schedule.nextDate.map {
            BillsCalendarEngine.relativeDueText(for: $0, status: status)
        }
    }

    private func relativeDateTint(_ status: ScheduleStatus) -> Color {
        switch status {
        case .missed: .red
        case .due: .orange
        case .upcoming, .scheduled: .blue
        case .paid: .green
        case .completed: Color(uiColor: .secondaryLabel)
        }
    }
}

#Preview {
    BudgetOverviewOverlay(month: "2026-09", onOpenSchedule: { _ in }, onDismiss: {})
        .environmentObject(BudgetStore.previewInstance())
}
