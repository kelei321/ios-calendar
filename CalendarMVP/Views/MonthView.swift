import SwiftUI

struct MonthView: View {
    @Binding var visibleMonth: Date
    @Binding var selectedDate: Date

    let events: [CalendarEvent]
    let holidayProvider: HolidayProvider
    let onEdit: (CalendarEvent) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekdays = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Button {
                        visibleMonth = DateHelper.chinaCalendar.date(byAdding: .month, value: -1, to: visibleMonth) ?? visibleMonth
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()

                    Button("今天") {
                        selectedDate = DateHelper.startOfDay(.now)
                        visibleMonth = selectedDate
                    }
                    .font(.callout.weight(.semibold))

                    Spacer()

                    Button {
                        visibleMonth = DateHelper.chinaCalendar.date(byAdding: .month, value: 1, to: visibleMonth) ?? visibleMonth
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.bordered)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(weekdays, id: \.self) { weekday in
                        Text(weekday)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }

                    ForEach(DateHelper.monthGrid(for: visibleMonth), id: \.self) { date in
                        MonthDayCell(
                            date: date,
                            visibleMonth: visibleMonth,
                            selectedDate: selectedDate,
                            events: eventsForDay(date),
                            holidays: holidayProvider.holidays(on: date)
                        )
                        .onTapGesture {
                            selectedDate = DateHelper.startOfDay(date)
                        }
                    }
                }

                DayView(
                    selectedDate: $selectedDate,
                    events: events,
                    holidayProvider: holidayProvider,
                    onEdit: onEdit
                )
                .frame(minHeight: 240)
            }
            .padding()
        }
    }

    private func eventsForDay(_ date: Date) -> [CalendarEvent] {
        let interval = DateHelper.dayInterval(containing: date)
        return events.filter { DateHelper.intersects($0, interval: interval) }
    }
}

private struct MonthDayCell: View {
    let date: Date
    let visibleMonth: Date
    let selectedDate: Date
    let events: [CalendarEvent]
    let holidays: [HolidayInfo]

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 2) {
                Text("\(DateHelper.chinaCalendar.component(.day, from: date))")
                    .font(.callout.weight(isToday ? .bold : .regular))

                if holidays.contains(where: \.isHoliday) {
                    Text("休")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 3)
                        .background(.red, in: Capsule())
                } else if holidays.contains(where: \.isWorkdayOverride) {
                    Text("班")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 3)
                        .background(.orange, in: Capsule())
                }
            }

            Text(holidays.first?.name ?? "")
                .font(.system(size: 9))
                .lineLimit(1)
                .foregroundStyle(holidays.first?.isWorkdayOverride == true ? .orange : .secondary)
                .frame(height: 11)

            HStack(spacing: 2) {
                ForEach(events.prefix(3), id: \.persistentModelID) { event in
                    Circle()
                        .fill(event.eventColor.swiftUIColor)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 58)
        .frame(maxWidth: .infinity)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .foregroundStyle(isInVisibleMonth ? .primary : .tertiary)
    }

    private var isToday: Bool {
        DateHelper.chinaCalendar.isDateInToday(date)
    }

    private var isSelected: Bool {
        DateHelper.chinaCalendar.isDate(date, inSameDayAs: selectedDate)
    }

    private var isInVisibleMonth: Bool {
        DateHelper.chinaCalendar.component(.month, from: date) == DateHelper.chinaCalendar.component(.month, from: visibleMonth)
    }

    @ViewBuilder private var background: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 8).fill(.blue.opacity(0.16))
        } else if isToday {
            RoundedRectangle(cornerRadius: 8).fill(.blue.opacity(0.08))
        } else {
            RoundedRectangle(cornerRadius: 8).fill(.clear)
        }
    }
}
