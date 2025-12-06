//
//  iTrackWatchApp.swift
//  iTrack WatchKit Extension
//
//  Main app entry point for watchOS
//

import SwiftUI

@main
struct iTrackWatchApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
