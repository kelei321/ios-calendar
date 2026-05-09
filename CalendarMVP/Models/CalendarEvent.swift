import Foundation
import SwiftData

@Model
final class CalendarEvent {
    var title: String
    var notes: String
    var location: String
    var startsAt: Date
    var endsAt: Date
    var isAllDay: Bool
    var colorName: String
    var reminderRawValue: String
    var createdAt: Date
    var updatedAt: Date

    init(
        title: String,
        notes: String = "",
        location: String = "",
        startsAt: Date,
        endsAt: Date,
        isAllDay: Bool = false,
        colorName: EventColor = .blue,
        reminder: ReminderOffset = .none,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.title = title
        self.notes = notes
        self.location = location
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.isAllDay = isAllDay
        self.colorName = colorName.rawValue
        self.reminderRawValue = reminder.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var reminder: ReminderOffset {
        get { ReminderOffset(rawValue: reminderRawValue) ?? .none }
        set { reminderRawValue = newValue.rawValue }
    }

    var eventColor: EventColor {
        get { EventColor(rawValue: colorName) ?? .blue }
        set { colorName = newValue.rawValue }
    }
}

enum ReminderOffset: String, Codable, CaseIterable, Identifiable {
    case none
    case atTime
    case fiveMinutes
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case oneDay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: "无"
        case .atTime: "准时"
        case .fiveMinutes: "提前 5 分钟"
        case .fifteenMinutes: "提前 15 分钟"
        case .thirtyMinutes: "提前 30 分钟"
        case .oneHour: "提前 1 小时"
        case .oneDay: "提前 1 天"
        }
    }

    var timeInterval: TimeInterval? {
        switch self {
        case .none: nil
        case .atTime: 0
        case .fiveMinutes: 5 * 60
        case .fifteenMinutes: 15 * 60
        case .thirtyMinutes: 30 * 60
        case .oneHour: 60 * 60
        case .oneDay: 24 * 60 * 60
        }
    }
}

enum EventColor: String, Codable, CaseIterable, Identifiable {
    case blue
    case green
    case orange
    case red
    case purple
    case gray

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .blue: "蓝色"
        case .green: "绿色"
        case .orange: "橙色"
        case .red: "红色"
        case .purple: "紫色"
        case .gray: "灰色"
        }
    }
}
