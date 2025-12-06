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
                .tabItem {
                    Label("Monitor", systemImage: AppIcons.heartRate)
                }

            EventListView()
                .tabItem {
                    Label("Eventos", systemImage: AppIcons.list)
                }

            SettingsView()
                .tabItem {
                    Label("Definições", systemImage: AppIcons.settings)
                }
        }
        .accentColor(AppTheme.Accent.lavender)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
