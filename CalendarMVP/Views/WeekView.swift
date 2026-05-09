import SwiftUI

struct WeekView: View {
    @Binding var selectedDate: Date

    let events: [CalendarEvent]
    let holidayProvider: HolidayProvider
    let onEdit: (CalendarEvent) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DateHelper.weekDays(containing: selectedDate), id: \.self) { date in
                        WeekDayPill(
                            date: date,
                            isSelected: DateHelper.chinaCalendar.isDate(date, inSameDayAs: selectedDate),
                            holidays: holidayProvider.holidays(on: date)
                        )
                        .onTapGesture {
                            selectedDate = DateHelper.startOfDay(date)
                        }
                    }
                }
                .padding()
            }

            DayView(selectedDate: $selectedDate, events: events, holidayProvider: holidayProvider, onEdit: onEdit)
        }
    }
}

private struct WeekDayPill: View {
    let date: Date
    let isSelected: Bool
    let holidays: [HolidayInfo]

    var body: some View {
        VStack(spacing: 5) {
            Text(weekday)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(DateHelper.chinaCalendar.component(.day, from: date))")
                .font(.title3.weight(.semibold))
            Text(holidayText)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 54)
        }
        .padding(.vertical, 10)
        .frame(width: 66)
        .background(isSelected ? .blue.opacity(0.16) : .secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }

    private var weekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    private var holidayText: String {
        holidays.first?.name ?? " "
    }
}
