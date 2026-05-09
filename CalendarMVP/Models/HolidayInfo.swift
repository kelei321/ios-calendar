import Foundation

struct HolidayInfo: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case statutory
        case workdayOverride
        case traditional
        case observance
    }

    let id: String
    let date: Date
    let name: String
    let kind: Kind
    let isHoliday: Bool
    let isWorkdayOverride: Bool
    let sourceYear: Int

    init(date: Date, name: String, kind: Kind, isHoliday: Bool = false, isWorkdayOverride: Bool = false, sourceYear: Int) {
        self.date = date
        self.name = name
        self.kind = kind
        self.isHoliday = isHoliday
        self.isWorkdayOverride = isWorkdayOverride
        self.sourceYear = sourceYear
        self.id = "\(sourceYear)-\(DateHelper.dayKey(for: date))-\(name)-\(kind.rawValue)"
    }
}
