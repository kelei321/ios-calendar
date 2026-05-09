import XCTest
@testable import CalendarMVP

final class CalendarMVPTests: XCTestCase {
    func testMonthGridStartsOnMondayAndHasSixWeeks() {
        let grid = DateHelper.monthGrid(for: DateHelper.date(2026, 5, 9))

        XCTAssertEqual(grid.count, 42)
        XCTAssertEqual(DateHelper.chinaCalendar.component(.weekday, from: grid[0]), 2)
    }

    func testOfficialHolidayAndWorkdayOverrides() {
        let provider = HolidayProvider()

        XCTAssertTrue(provider.isHoliday(DateHelper.date(2026, 10, 1)))
        XCTAssertTrue(provider.isWorkdayOverride(DateHelper.date(2026, 10, 10)))
        XCTAssertTrue(provider.isHoliday(DateHelper.date(2025, 1, 29)))
        XCTAssertTrue(provider.isWorkdayOverride(DateHelper.date(2025, 2, 8)))
    }

    func testMotherAndFatherDayRules() {
        let provider = HolidayProvider()

        XCTAssertTrue(provider.holidays(on: DateHelper.date(2026, 5, 10)).contains { $0.name == "母亲节" })
        XCTAssertTrue(provider.holidays(on: DateHelper.date(2026, 6, 21)).contains { $0.name == "父亲节" })
        XCTAssertTrue(provider.holidays(on: DateHelper.date(2025, 5, 11)).contains { $0.name == "母亲节" })
        XCTAssertTrue(provider.holidays(on: DateHelper.date(2025, 6, 15)).contains { $0.name == "父亲节" })
    }

    func testTraditionalHolidayDates() {
        let provider = HolidayProvider()

        XCTAssertTrue(provider.holidays(on: DateHelper.date(2025, 2, 12)).contains { $0.name == "元宵节" })
        XCTAssertTrue(provider.holidays(on: DateHelper.date(2025, 10, 29)).contains { $0.name == "重阳节" })
        XCTAssertTrue(provider.holidays(on: DateHelper.date(2026, 3, 3)).contains { $0.name == "元宵节" })
    }

    func testReminderOffsets() {
        XCTAssertEqual(ReminderOffset.fifteenMinutes.timeInterval, 15 * 60)
        XCTAssertNil(ReminderOffset.none.timeInterval)
    }
}
