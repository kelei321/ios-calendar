import SwiftData
import SwiftUI

struct EventEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationScheduler.self) private var notificationScheduler

    private let event: CalendarEvent?
    private let defaultDate: Date

    @State private var title: String
    @State private var notes: String
    @State private var location: String
    @State private var startsAt: Date
    @State private var endsAt: Date
    @State private var isAllDay: Bool
    @State private var color: EventColor
    @State private var reminder: ReminderOffset

    init(event: CalendarEvent?, defaultDate: Date) {
        self.event = event
        self.defaultDate = defaultDate
        let start = event?.startsAt ?? EventEditorView.defaultStart(on: defaultDate)
        _title = State(initialValue: event?.title ?? "")
        _notes = State(initialValue: event?.notes ?? "")
        _location = State(initialValue: event?.location ?? "")
        _startsAt = State(initialValue: start)
        _endsAt = State(initialValue: event?.endsAt ?? DateHelper.chinaCalendar.date(byAdding: .hour, value: 1, to: start) ?? start)
        _isAllDay = State(initialValue: event?.isAllDay ?? false)
        _color = State(initialValue: event?.eventColor ?? .blue)
        _reminder = State(initialValue: event?.reminder ?? .none)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("标题", text: $title)
                    TextField("地点", text: $location)
                }

                Section("时间") {
                    Toggle("全天", isOn: $isAllDay)
                    DatePicker("开始", selection: $startsAt, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                    DatePicker("结束", selection: $endsAt, in: startsAt..., displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                }

                Section("提醒") {
                    Picker("提醒", selection: $reminder) {
                        ForEach(ReminderOffset.allCases) { offset in
                            Text(offset.displayName).tag(offset)
                        }
                    }
                }

                Section("颜色") {
                    Picker("颜色", selection: $color) {
                        ForEach(EventColor.allCases) { item in
                            Label(item.displayName, systemImage: "circle.fill")
                                .foregroundStyle(item.swiftUIColor)
                                .tag(item)
                        }
                    }
                }

                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 110)
                }
            }
            .navigationTitle(event == nil ? "新建日程" : "编辑日程")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let target = event ?? CalendarEvent(title: trimmedTitle, startsAt: startsAt, endsAt: endsAt)
        target.title = trimmedTitle
        target.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        target.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        target.startsAt = startsAt
        target.endsAt = max(endsAt, startsAt)
        target.isAllDay = isAllDay
        target.eventColor = color
        target.reminder = reminder
        target.updatedAt = .now

        if event == nil {
            modelContext.insert(target)
        }

        Task {
            await notificationScheduler.scheduleReminder(for: target)
        }

        dismiss()
    }

    private static func defaultStart(on date: Date) -> Date {
        let now = Date()
        var components = DateHelper.chinaCalendar.dateComponents([.year, .month, .day], from: date)
        let currentHour = DateHelper.chinaCalendar.component(.hour, from: now)
        components.hour = min(currentHour + 1, 23)
        components.minute = 0
        return DateHelper.chinaCalendar.date(from: components) ?? date
    }
}
