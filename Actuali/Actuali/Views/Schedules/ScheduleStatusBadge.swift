import SwiftUI

/// Status pill for a schedule row, mirroring the web's `StatusBadge`.
struct ScheduleStatusBadge: View {
    let status: ScheduleStatus
    var label: String? = nil
    var tint: Color? = nil
    @Environment(\.locale) private var locale

    var body: some View {
        let statusLabel = label ?? ScheduleDescription.statusLabel(status, locale: locale)
        let badgeTint = tint ?? status.tint

        return Text(statusLabel)
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(badgeTint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeTint.opacity(0.14), in: Capsule())
            .accessibilityLabel(ReportStrings.format("Status: %@", statusLabel, locale: locale))
    }
}

extension ScheduleStatus {
    var tint: Color {
        switch self {
        case .missed: .red
        case .due: .orange
        case .upcoming: .blue
        case .paid: .green
        case .completed: .secondary
        case .scheduled: .secondary
        }
    }
}
