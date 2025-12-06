//
//  FixSleepWatchApp.swift
//  FixSleep WatchKit Extension
//
//  Main app entry point for watchOS
//

import SwiftUI

@main
struct FixSleepWatchApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
