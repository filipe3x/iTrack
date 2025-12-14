//
//  ExtensionDelegate.swift
//  iTrack WatchKit Extension
//
//  Extension delegate for watchOS app lifecycle
//

import WatchKit
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {

    func applicationDidFinishLaunching() {
        print("[ExtensionDelegate] FixSleep Watch Extension launched")

        // Start WatchConnectivity so the phone can see this watch app immediately
        WatchConnectivityManager.shared.activate()

        // Start activation retry for simulator reliability
        WatchConnectivityManager.shared.startActivationRetry()

        // Setup notification categories
        HapticManager.shared.setupNotificationCategories()

        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
    }

    func applicationDidBecomeActive() {
        print("[ExtensionDelegate] FixSleep Watch Extension became active")

        // Re-activate and probe connection when app becomes active
        WatchConnectivityManager.shared.activate()
        WatchConnectivityManager.shared.probeConnection()
    }

    func applicationWillResignActive() {
        print("FixSleep Watch Extension will resign active")
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Handle background refresh
                print("Background refresh task")
                backgroundTask.setTaskCompletedWithSnapshot(false)

            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Handle snapshot refresh
                print("Snapshot refresh task")
                snapshotTask.setTaskCompleted(
                    restoredDefaultState: true,
                    estimatedSnapshotExpiration: Date.distantFuture,
                    userInfo: nil
                )

            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Handle WatchConnectivity background task
                print("WatchConnectivity background task")
                connectivityTask.setTaskCompletedWithSnapshot(false)

            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Handle URL session background task
                print("URLSession background task")
                urlSessionTask.setTaskCompletedWithSnapshot(false)

            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        if #available(watchOS 8.0, *) {
            completionHandler([.banner, .sound])
        } else {
            // On older watchOS we only play sound to avoid deprecated .alert
            completionHandler([.sound])
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification response
        HapticManager.shared.handleNotificationResponse(response)
        completionHandler()
    }
}
