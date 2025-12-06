//
//  ContentView.swift
//  iTrack WatchKit Extension
//
//  Main view for watchOS app
//

import SwiftUI

struct ContentView: View {
    @StateObject private var heartRateMonitor = HeartRateMonitor.shared
    @StateObject private var dataManager = DataManager.shared

    var body: some View {
        TabView {
            MonitoringView()
                .tabItem {
                    Label("Monitor", systemImage: "heart.fill")
                }

            EventListView()
                .tabItem {
                    Label("Events", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
