//
//  FixSleepApp.swift
//  FixSleep
//
//  Main app entry point for iOS
//

import SwiftUI

@main
struct FixSleepApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize WatchConnectivity
        WatchConnectivityManager.shared.activate()

        // Request notification permissions
        NotificationManager.shared.requestAuthorization()

        return true
    }
}
