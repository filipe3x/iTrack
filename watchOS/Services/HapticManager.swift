//
//  HapticManager.swift
//  iTrack WatchKit Extension
//
//  Manages haptic feedback and alerts
//

import Foundation
import WatchKit
import UserNotifications

/// Manages haptic feedback and notification alerts
class HapticManager {
    static let shared = HapticManager()

    private init() {
        requestNotificationAuthorization()
    }

    // MARK: - Notification Authorization

    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }

            print("Notification authorization granted: \(granted)")
        }
    }

    // MARK: - Alert Triggering

    /// Trigger alert for a detection event
    func triggerAlert(for event: DetectionEvent) {
        let settings = DataManager.shared.settings

        // Play haptic
        if settings.enableHaptics {
            playHaptic()
        }

        // Send local notification
        sendNotification(for: event, withSound: settings.enableAudibleAlarm)
    }

    // MARK: - Haptics

    /// Play haptic feedback
    private func playHaptic() {
        // Use notification haptic for important alerts
        WKInterfaceDevice.current().play(.notification)

        // For more persistent alert, play multiple times
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            WKInterfaceDevice.current().play(.notification)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            WKInterfaceDevice.current().play(.notification)
        }
    }

    /// Play success haptic (for acknowledgment)
    func playSuccessHaptic() {
        WKInterfaceDevice.current().play(.success)
    }

    /// Play failure haptic
    func playFailureHaptic() {
        WKInterfaceDevice.current().play(.failure)
    }

    // MARK: - Notifications

    /// Send local notification for detection event
    private func sendNotification(for event: DetectionEvent, withSound: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "Arousal Event Detected"
        content.body = "Heart rate: \(Int(event.heartRateAtDetection)) bpm"
        content.categoryIdentifier = "AROUSAL_EVENT"

        if withSound {
            content.sound = .defaultCritical
        }

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

    // MARK: - Notification Actions

    /// Setup notification categories and actions
    func setupNotificationCategories() {
        let acknowledgeAction = UNNotificationAction(
            identifier: "ACKNOWLEDGE",
            title: "Acknowledge",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze 5min",
            options: []
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: [.destructive]
        )

        let category = UNNotificationCategory(
            identifier: "AROUSAL_EVENT",
            actions: [acknowledgeAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    /// Handle notification response
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        guard let eventIdString = response.notification.request.content.userInfo["eventId"] as? String,
              let eventId = UUID(uuidString: eventIdString) else {
            return
        }

        // Find the event
        let events = DataManager.shared.loadAllEvents()
        guard var event = events.first(where: { $0.id == eventId }) else {
            return
        }

        // Update event based on action
        switch response.actionIdentifier {
        case "ACKNOWLEDGE":
            event.alertResponse = .acknowledged
            event.responseTime = Date()
            playSuccessHaptic()

        case "SNOOZE":
            event.alertResponse = .snoozed
            event.responseTime = Date()
            // Could schedule a reminder in 5 minutes

        case "DISMISS":
            event.alertResponse = .dismissed
            event.responseTime = Date()

        default:
            break
        }

        // Save updated event
        DataManager.shared.updateEvent(event)
    }
}
