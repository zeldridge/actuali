import Testing
@testable import Actuali

struct BudgetOverviewSchedulesTests {
    @Test func includesOnlyActiveSchedulesWhoseNextDateIsInTheViewedMonth() {
        let september = schedule(id: "september", nextDate: 20_260_915)
        let october = schedule(id: "october", nextDate: 20_261_001)
        let completed = schedule(id: "completed", nextDate: 20_260_920, completed: true)
        let broken = schedule(id: "broken", nextDate: nil)

        let result = BudgetOverviewSchedules.forMonth(
            "2026-09",
            schedules: [september, october, completed, broken]
        )

        #expect(result.map(\.id) == ["september"])
    }

    @Test func rejectsMalformedMonthKeys() {
        #expect(BudgetOverviewSchedules.forMonth("2026-13", schedules: []).isEmpty)
        #expect(BudgetOverviewSchedules.forMonth("September", schedules: []).isEmpty)
    }

    private func schedule(id: String, nextDate: Int?, completed: Bool = false) -> ScheduleSummary {
        ScheduleSummary(
            id: id,
            name: id,
            ruleId: nil,
            nextDate: nextDate.flatMap(DayDate.init(yyyymmdd:)),
            nextDateRowId: nil,
            baseNextDateTs: nil,
            accountId: nil,
            payeeId: nil,
            amount: .fixed(-1_000),
            amountOp: .isExactly,
            dateOp: nil,
            dateCondition: nil,
            postsTransaction: false,
            completed: completed,
            customUpcomingLength: nil,
            sortOrder: nil,
            isCustom: false,
            conditionsJSON: nil,
            actionsJSON: nil,
            categoryId: nil
        )
    }
}
