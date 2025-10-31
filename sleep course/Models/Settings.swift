import Foundation
import SwiftData
import UserNotifications

@Model
final class Settings {
    var _notificationTime: Date

    var notificationTime: Date {
        get { _notificationTime }
        set {
            let oldValue = _notificationTime
            guard oldValue != newValue else {
                return
            }
            _notificationTime = newValue

            Task { @MainActor in
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: ["daily_ritual"])

                let content = UNMutableNotificationContent()
                content.title = "Время ритуала"
                content.body = "Пора начать вечерний ритуал для здорового сна 🌙"
                content.sound = .default

                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: "daily_ritual",
                                                    content: content,
                                                    trigger: trigger)
                try await center.add(request)
                _ = await center.pendingNotificationRequests()
            }
        }
    }

    init() {
        _notificationTime = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
    }

    static func primary(from collection: [Settings]) -> Settings? {
        collection.first
    }
}
