import Foundation

enum BudgetOverviewSchedules {
    /// The overview is a month-filtered window onto the same active schedules
    /// shown in Settings, not a separate projection of future occurrences.
    static func forMonth(_ monthKey: String, schedules: [ScheduleSummary]) -> [ScheduleSummary] {
        let parts = monthKey.split(separator: "-")
        guard parts.count == 2,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              (1...12).contains(month)
        else { return [] }

        return schedules.filter { schedule in
            !schedule.completed
                && schedule.nextDate?.year == year
                && schedule.nextDate?.month == month
        }
    }
}
