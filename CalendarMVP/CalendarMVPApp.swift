import SwiftData
import SwiftUI

@main
struct CalendarMVPApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: CalendarEvent.self)
        } catch {
            fatalError("Unable to create SwiftData model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootCalendarView()
                .environment(HolidayProvider())
                .environment(NotificationScheduler())
        }
        .modelContainer(modelContainer)
    }
}
