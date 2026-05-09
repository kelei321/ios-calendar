import Foundation
import SwiftUI

@Observable
final class HolidayProvider {
    private let fixedHolidays: [String: [HolidayInfo]]

    init() {
        fixedHolidays = HolidayProvider.makeFixedHolidays()
    }

    func holidays(on date: Date) -> [HolidayInfo] {
        let key = DateHelper.dayKey(for: date)
        let year = DateHelper.chinaCalendar.component(.year, from: date)
        var results = fixedHolidays[key] ?? []

        if DateHelper.dayKey(for: DateHelper.nthWeekday(1, ordinal: 2, month: 5, year: year)) == key {
            results.append(.init(date: DateHelper.startOfDay(date), name: "母亲节", kind: .observance, sourceYear: year))
        }

        if DateHelper.dayKey(for: DateHelper.nthWeekday(1, ordinal: 3, month: 6, year: year)) == key {
            results.append(.init(date: DateHelper.startOfDay(date), name: "父亲节", kind: .observance, sourceYear: year))
        }

        return results.sorted { lhs, rhs in
            if lhs.isWorkdayOverride != rhs.isWorkdayOverride {
                return !lhs.isWorkdayOverride
            }
            return lhs.name < rhs.name
        }
    }

    func holidays(in range: DateInterval) -> [HolidayInfo] {
        var date = DateHelper.startOfDay(range.start)
        var results: [HolidayInfo] = []

        while date < range.end {
            results.append(contentsOf: holidays(on: date))
            guard let next = DateHelper.chinaCalendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }

        return results
    }

    func isWorkdayOverride(_ date: Date) -> Bool {
        holidays(on: date).contains { $0.isWorkdayOverride }
    }

    func isHoliday(_ date: Date) -> Bool {
        holidays(on: date).contains { $0.isHoliday }
    }

    private static func makeFixedHolidays() -> [String: [HolidayInfo]] {
        var values: [String: [HolidayInfo]] = [:]

        func add(_ year: Int, _ month: Int, _ day: Int, _ name: String, _ kind: HolidayInfo.Kind, holiday: Bool = false, workday: Bool = false) {
            let date = DateHelper.date(year, month, day)
            let key = DateHelper.dayKey(for: date)
            values[key, default: []].append(
                HolidayInfo(date: date, name: name, kind: kind, isHoliday: holiday, isWorkdayOverride: workday, sourceYear: year)
            )
        }

        for day in 1...1 { add(2025, 1, day, "元旦", .statutory, holiday: true) }
        for day in 28...31 { add(2025, 1, day, "春节假期", .statutory, holiday: true) }
        for day in 1...4 { add(2025, 2, day, "春节假期", .statutory, holiday: true) }
        add(2025, 1, 26, "春节调休上班", .workdayOverride, workday: true)
        add(2025, 2, 8, "春节调休上班", .workdayOverride, workday: true)
        for day in 4...6 { add(2025, 4, day, "清明节", .statutory, holiday: true) }
        for day in 1...5 { add(2025, 5, day, "劳动节", .statutory, holiday: true) }
        add(2025, 4, 27, "劳动节调休上班", .workdayOverride, workday: true)
        add(2025, 5, 31, "端午节", .statutory, holiday: true)
        for day in 1...2 { add(2025, 6, day, "端午节", .statutory, holiday: true) }
        for day in 1...8 { add(2025, 10, day, day == 6 ? "国庆节/中秋节" : "国庆节", .statutory, holiday: true) }
        add(2025, 9, 28, "国庆节调休上班", .workdayOverride, workday: true)
        add(2025, 10, 11, "国庆节调休上班", .workdayOverride, workday: true)

        add(2025, 1, 28, "除夕", .traditional)
        add(2025, 1, 29, "春节", .traditional)
        add(2025, 2, 12, "元宵节", .traditional)
        add(2025, 8, 29, "七夕", .traditional)
        add(2025, 10, 29, "重阳节", .traditional)

        for day in 1...3 { add(2026, 1, day, "元旦", .statutory, holiday: true) }
        add(2026, 1, 4, "元旦调休上班", .workdayOverride, workday: true)
        for day in 15...23 { add(2026, 2, day, "春节假期", .statutory, holiday: true) }
        add(2026, 2, 14, "春节调休上班", .workdayOverride, workday: true)
        add(2026, 2, 28, "春节调休上班", .workdayOverride, workday: true)
        for day in 4...6 { add(2026, 4, day, "清明节", .statutory, holiday: true) }
        for day in 1...5 { add(2026, 5, day, "劳动节", .statutory, holiday: true) }
        add(2026, 5, 9, "劳动节调休上班", .workdayOverride, workday: true)
        for day in 19...21 { add(2026, 6, day, "端午节", .statutory, holiday: true) }
        for day in 25...27 { add(2026, 9, day, "中秋节", .statutory, holiday: true) }
        for day in 1...7 { add(2026, 10, day, "国庆节", .statutory, holiday: true) }
        add(2026, 9, 20, "国庆节调休上班", .workdayOverride, workday: true)
        add(2026, 10, 10, "国庆节调休上班", .workdayOverride, workday: true)

        add(2026, 2, 16, "除夕", .traditional)
        add(2026, 2, 17, "春节", .traditional)
        add(2026, 3, 3, "元宵节", .traditional)
        add(2026, 8, 19, "七夕", .traditional)
        add(2026, 10, 18, "重阳节", .traditional)

        return values
    }
}
