//
//  DashboardView.swift
//  iTrack
//
//  Dashboard showing current status and recent activity
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Watch connection status
                    watchStatusCard

                    // Sleep window card
                    sleepWindowCard

                    // Recent activity summary
                    recentActivityCard

                    // Quick actions
                    quickActionsCard
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    private var watchStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "applewatch")
                    .font(.title2)
                    .foregroundColor(watchConnectivity.isWatchAppInstalled ? .green : .gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple Watch")
                        .font(.headline)

                    Text(watchConnectivity.isWatchAppInstalled ? "Connected" : "Not Connected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if watchConnectivity.isWatchAppInstalled {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            if !watchConnectivity.isWatchAppInstalled {
                Text("Install iTrack on your Apple Watch to start monitoring")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var sleepWindowCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "moon.fill")
                    .font(.title2)
                    .foregroundColor(.blue)

                Text("Sleep Window")
                    .font(.headline)

                Spacer()
            }

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(sleepStartTime)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("End")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(sleepEndTime)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()
            }

            if dataManager.settings.isWithinSleepWindow() {
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)

                    Text("Currently in sleep window")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var recentActivityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.purple)

                Text("Recent Activity")
                    .font(.headline)

                Spacer()

                NavigationLink(destination: EventLogView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            if dataManager.recentEvents.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars")
                        .font(.largeTitle)
                        .foregroundColor(.gray)

                    Text("No recent events")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    statsRow(
                        title: "Today's Events",
                        value: todayEventCount,
                        icon: "bell.fill",
                        color: .orange
                    )

                    statsRow(
                        title: "This Week",
                        value: weekEventCount,
                        icon: "calendar",
                        color: .blue
                    )

                    if let lastEvent = dataManager.recentEvents.last {
                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last Event")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(lastEvent.detectionType.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }

                            Spacer()

                            Text(formatRelativeTime(lastEvent.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            VStack(spacing: 12) {
                NavigationLink(destination: SettingsView()) {
                    QuickActionButton(
                        icon: "slider.horizontal.3",
                        title: "Adjust Sensitivity",
                        color: .blue
                    )
                }

                NavigationLink(destination: EventLogView()) {
                    QuickActionButton(
                        icon: "square.and.arrow.up",
                        title: "Export Event Log",
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Helper Views

    private func statsRow(title: String, value: Int, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)

            Text(title)
                .font(.subheadline)

            Spacer()

            Text("\(value)")
                .font(.headline)
                .fontWeight(.semibold)
        }
    }

    // MARK: - Computed Properties

    private var sleepStartTime: String {
        formatTime(
            hour: dataManager.settings.sleepWindowStart.hour ?? 22,
            minute: dataManager.settings.sleepWindowStart.minute ?? 0
        )
    }

    private var sleepEndTime: String {
        formatTime(
            hour: dataManager.settings.sleepWindowEnd.hour ?? 7,
            minute: dataManager.settings.sleepWindowEnd.minute ?? 0
        )
    }

    private var todayEventCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return dataManager.recentEvents.filter {
            Calendar.current.isDate($0.timestamp, inSameDayAs: today)
        }.count
    }

    private var weekEventCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return dataManager.recentEvents.filter { $0.timestamp > weekAgo }.count
    }

    // MARK: - Helper Functions

    private func formatTime(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }

        return "--:--"
    }

    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            Text(title)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
