import Foundation
import Observation
import UserNotifications

@Observable
final class NotificationScheduler {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        await refreshAuthorizationStatus()
        if authorizationStatus == .authorized || authorizationStatus == .provisional {
            return true
        }

        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            return false
        }
    }

    func scheduleReminder(for event: CalendarEvent) async {
        guard let offset = event.reminder.timeInterval else {
            cancelReminder(for: event)
            return
        }

        let fireDate = event.startsAt.addingTimeInterval(-offset)
        guard fireDate > .now else {
            cancelReminder(for: event)
            return
        }

        guard await requestAuthorizationIfNeeded() else { return }

        let content = UNMutableNotificationContent()
        content.title = event.title.isEmpty ? "日程提醒" : event.title
        content.body = event.location.isEmpty ? "即将开始" : event.location
        content.sound = .default

        let components = DateHelper.chinaCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier(for: event), content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for event: CalendarEvent) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier(for: event)])
    }

    private func identifier(for event: CalendarEvent) -> String {
        "calendar-event-\(event.persistentModelID)"
    }
}
