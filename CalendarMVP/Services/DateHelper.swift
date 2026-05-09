import Foundation

enum DateHelper {
    static var chinaCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.timeZone = .current
        calendar.firstWeekday = 2
        return calendar
    }

    static func startOfDay(_ date: Date) -> Date {
        chinaCalendar.startOfDay(for: date)
    }

    static func dayKey(for date: Date) -> String {
        let components = chinaCalendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        chinaCalendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    static func monthGrid(for visibleMonth: Date) -> [Date] {
        let calendar = chinaCalendar
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: visibleMonth)) ?? visibleMonth
        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingDays = (weekday - calendar.firstWeekday + 7) % 7
        let gridStart = calendar.date(byAdding: .day, value: -leadingDays, to: monthStart) ?? monthStart
        return (0..<42).compactMap { calendar.date(byAdding: .day, value: $0, to: gridStart) }
    }

    static func weekDays(containing date: Date) -> [Date] {
        let calendar = chinaCalendar
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? startOfDay(date)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    static func monthInterval(containing date: Date) -> DateInterval {
        chinaCalendar.dateInterval(of: .month, for: date) ?? DateInterval(start: startOfDay(date), duration: 30 * 24 * 60 * 60)
    }

    static func dayInterval(containing date: Date) -> DateInterval {
        chinaCalendar.dateInterval(of: .day, for: date) ?? DateInterval(start: startOfDay(date), duration: 24 * 60 * 60)
    }

    static func intersects(_ event: CalendarEvent, interval: DateInterval) -> Bool {
        DateInterval(start: event.startsAt, end: event.endsAt).intersects(interval)
    }

    static func nthWeekday(_ weekday: Int, ordinal: Int, month: Int, year: Int) -> Date {
        let first = date(year, month, 1)
        let firstWeekday = chinaCalendar.component(.weekday, from: first)
        let offset = (weekday - firstWeekday + 7) % 7
        return chinaCalendar.date(byAdding: .day, value: offset + (ordinal - 1) * 7, to: first) ?? first
    }
}
