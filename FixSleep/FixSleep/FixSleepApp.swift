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
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                print("[FixSleepApp] App became active")
                // Re-activate and probe when app comes to foreground
                WatchConnectivityManager.shared.activate()
                WatchConnectivityManager.shared.probeConnection()
            case .inactive:
                print("[FixSleepApp] App became inactive")
            case .background:
                print("[FixSleepApp] App entered background")
                WatchConnectivityManager.shared.stopActivationRetry()
            @unknown default:
                break
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        print("[AppDelegate] FixSleep iOS app launched")

        // Initialize WatchConnectivity early
        WatchConnectivityManager.shared.activate()

        // Start activation retry for simulator reliability
        WatchConnectivityManager.shared.startActivationRetry()

        // Request notification permissions
        NotificationManager.shared.requestAuthorization()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("[AppDelegate] App became active - re-probing connection")
        WatchConnectivityManager.shared.probeConnection()
    }
}
