//
//  NotificationManager.swift
//  iTrack
//
//  Manages notifications on iOS (fallback when watch not worn)
//

import Foundation
import UserNotifications

/// Manages local notifications for the iOS app
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private override init() {
        super.init()
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }

            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }

        // Set delegate
        UNUserNotificationCenter.current().delegate = self
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Send Notifications

    /// Send fallback notification when watch is not worn
    func sendFallbackNotification(for event: DetectionEvent) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Arousal Event Detected"
        content.body = "Heart rate elevated to \(Int(event.heartRateAtDetection)) bpm"
        content.sound = .defaultCritical
        content.badge = NSNumber(value: 1)

        // Add custom data
        content.userInfo = [
            "eventId": event.id.uuidString,
            "heartRate": event.heartRateAtDetection,
            "timestamp": event.timestamp.timeIntervalSince1970
        ]

        // Create trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: trigger
        )

        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    /// Send reminder notification for sleep window
    func scheduleSleepWindowReminder(startTime: DateComponents) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Sleep Monitoring"
        content.body = "Your sleep monitoring window is starting soon. Make sure your Apple Watch is worn and charged."
        content.sound = .default

        // Create trigger 15 minutes before sleep window
        var reminderTime = startTime
        reminderTime.minute = (startTime.minute ?? 0) - 15

        let trigger = UNCalendarNotificationTrigger(dateMatching: reminderTime, repeats: true)

        let request = UNNotificationRequest(
            identifier: "sleepWindowReminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error.localizedDescription)")
            }
        }
    }

    /// Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    /// Clear badge
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        if let eventIdString = response.notification.request.content.userInfo["eventId"] as? String,
           let eventId = UUID(uuidString: eventIdString) {

            // Find and display the event
            print("User tapped notification for event: \(eventId)")

            // Could navigate to event detail view here
        }

        clearBadge()
        completionHandler()
    }
}
