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
        print("iTrack Watch Extension launched")

        // Setup notification categories
        HapticManager.shared.setupNotificationCategories()

        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
    }

    func applicationDidBecomeActive() {
        print("iTrack Watch Extension became active")
    }

    func applicationWillResignActive() {
        print("iTrack Watch Extension will resign active")
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
        completionHandler([.banner, .sound])
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
