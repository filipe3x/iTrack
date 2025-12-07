//
//  ContentView.swift
//  FixSleep WatchKit Extension
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

            EventListView()

            SettingsView()
        }
        .tabViewStyle(.page)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
