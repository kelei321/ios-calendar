import SwiftData
import SwiftUI

struct RootCalendarView: View {
    @Environment(HolidayProvider.self) private var holidayProvider
    @Query(sort: \CalendarEvent.startsAt) private var events: [CalendarEvent]

    @State private var selectedDate = DateHelper.startOfDay(.now)
    @State private var visibleMonth = DateHelper.startOfDay(.now)
    @State private var tab: CalendarTab = .month
    @State private var isPresentingEditor = false
    @State private var editingEvent: CalendarEvent?

    var body: some View {
        NavigationStack {
            Group {
                switch tab {
                case .month:
                    MonthView(
                        visibleMonth: $visibleMonth,
                        selectedDate: $selectedDate,
                        events: events,
                        holidayProvider: holidayProvider,
                        onEdit: edit
                    )
                case .week:
                    WeekView(
                        selectedDate: $selectedDate,
                        events: events,
                        holidayProvider: holidayProvider,
                        onEdit: edit
                    )
                case .day:
                    DayView(
                        selectedDate: $selectedDate,
                        events: events,
                        holidayProvider: holidayProvider,
                        onEdit: edit
                    )
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SearchView(events: events, onEdit: edit)
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibilityLabel("搜索")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingEvent = nil
                        isPresentingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("新建日程")
                }
            }
            .safeAreaInset(edge: .bottom) {
                Picker("视图", selection: $tab) {
                    ForEach(CalendarTab.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(.bar)
            }
            .sheet(isPresented: $isPresentingEditor) {
                EventEditorView(event: editingEvent, defaultDate: selectedDate)
            }
        }
    }

    private var navigationTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.calendar = DateHelper.chinaCalendar
        formatter.dateFormat = tab == .month ? "yyyy年M月" : "M月d日"
        return formatter.string(from: tab == .month ? visibleMonth : selectedDate)
    }

    private func edit(_ event: CalendarEvent) {
        editingEvent = event
        isPresentingEditor = true
    }
}

private enum CalendarTab: String, CaseIterable, Identifiable {
    case month
    case week
    case day

    var id: String { rawValue }

    var title: String {
        switch self {
        case .month: "月"
        case .week: "周"
        case .day: "日"
        }
    }
}
