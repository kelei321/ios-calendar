import SwiftUI

struct SearchView: View {
    let events: [CalendarEvent]
    let onEdit: (CalendarEvent) -> Void

    @State private var query = ""

    var body: some View {
        List {
            if results.isEmpty {
                ContentUnavailableView("没有匹配日程", systemImage: "magnifyingglass")
            } else {
                ForEach(results, id: \.persistentModelID) { event in
                    EventRow(event: event)
                        .contentShape(Rectangle())
                        .onTapGesture { onEdit(event) }
                }
            }
        }
        .navigationTitle("搜索")
        .searchable(text: $query, prompt: "标题、地点或备注")
    }

    private var results: [CalendarEvent] {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return [] }
        return events.filter { event in
            event.title.localizedCaseInsensitiveContains(text)
            || event.location.localizedCaseInsensitiveContains(text)
            || event.notes.localizedCaseInsensitiveContains(text)
        }
    }
}
