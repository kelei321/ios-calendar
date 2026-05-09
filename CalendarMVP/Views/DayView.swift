import SwiftUI

struct DayView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDate: Date

    let events: [CalendarEvent]
    let holidayProvider: HolidayProvider
    let onEdit: (CalendarEvent) -> Void

    var body: some View {
        List {
            let holidays = holidayProvider.holidays(on: selectedDate)
            if !holidays.isEmpty {
                Section("节日") {
                    ForEach(holidays) { holiday in
                        HStack {
                            Label(holiday.name, systemImage: iconName(for: holiday))
                            Spacer()
                            Text(label(for: holiday))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(color(for: holiday))
                        }
                    }
                }
            }

            Section("日程") {
                let dayEvents = eventsForSelectedDay
                if dayEvents.isEmpty {
                    ContentUnavailableView("暂无日程", systemImage: "calendar")
                } else {
                    ForEach(dayEvents, id: \.persistentModelID) { event in
                        EventRow(event: event)
                            .contentShape(Rectangle())
                            .onTapGesture { onEdit(event) }
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var eventsForSelectedDay: [CalendarEvent] {
        let interval = DateHelper.dayInterval(containing: selectedDate)
        return events
            .filter { DateHelper.intersects($0, interval: interval) }
            .sorted { lhs, rhs in
                if lhs.isAllDay != rhs.isAllDay { return lhs.isAllDay }
                return lhs.startsAt < rhs.startsAt
            }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(eventsForSelectedDay[index])
        }
    }

    private func iconName(for holiday: HolidayInfo) -> String {
        holiday.isWorkdayOverride ? "briefcase" : "sun.max"
    }

    private func label(for holiday: HolidayInfo) -> String {
        if holiday.isWorkdayOverride { return "上班" }
        if holiday.isHoliday { return "休息" }
        return "纪念"
    }

    private func color(for holiday: HolidayInfo) -> Color {
        if holiday.isWorkdayOverride { return .orange }
        if holiday.isHoliday { return .red }
        return .secondary
    }
}

struct EventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.eventColor.swiftUIColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title.isEmpty ? "未命名日程" : event.title)
                    .font(.headline)
                Text(timeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !event.location.isEmpty {
                    Text(event.location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var timeText: String {
        if event.isAllDay { return "全天" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: event.startsAt)) - \(formatter.string(from: event.endsAt))"
    }
}
