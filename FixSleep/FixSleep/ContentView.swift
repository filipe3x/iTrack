//
//  ContentView.swift
//  FixSleep
//
//  Main view for iOS app
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared

    @State private var selectedTab = 0
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            // Night sky background
            NightSkyBackground()
                .ignoresSafeArea()

            // Tab view with themed styling
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: AppIcons.heartRate)
                    }
                    .tag(0)

                EventLogView()
                    .tabItem {
                        Label("Eventos", systemImage: AppIcons.list)
                    }
                    .tag(1)

                SettingsView()
                    .tabItem {
                        Label("Definições", systemImage: AppIcons.settings)
                    }
                    .tag(2)
            }
            .accentColor(AppTheme.Accent.lavender)
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .onAppear {
            checkOnboardingStatus()
        }
        .preferredColorScheme(.dark)
    }

    private func checkOnboardingStatus() {
        // Show onboarding if HealthKit not authorized
        if !healthKitManager.isAuthorized {
            showOnboarding = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
