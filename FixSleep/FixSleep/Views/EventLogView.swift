//
//  EventLogView.swift
//  iTrack
//
//  Detailed event log with export functionality
//

import SwiftUI

struct EventLogView: View {
    @StateObject private var dataManager = DataManager.shared

    @State private var showExportOptions = false
    @State private var showShareSheet = false
    @State private var exportData: String = ""

    var body: some View {
        List {
            if dataManager.recentEvents.isEmpty {
                emptyStateView
            } else {
                ForEach(groupedEvents.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(formatSectionHeader(date))) {
                        ForEach(groupedEvents[date] ?? []) { event in
                            EventDetailRow(event: event)
                        }
                    }
                }

                Section {
                    Button(action: { showExportOptions = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Event Log")
                        }
                        .foregroundColor(.blue)
                    }

                    Button(action: clearAllEvents) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear All Events")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Event Log")
        .actionSheet(isPresented: $showExportOptions) {
            ActionSheet(
                title: Text("Export Format"),
                buttons: [
                    .default(Text("Export as JSON")) {
                        exportAsJSON()
                    },
                    .default(Text("Export as CSV")) {
                        exportAsCSV()
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [exportData])
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Events Recorded")
                .font(.headline)

            Text("Events will appear here when detected by your Apple Watch during monitoring")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .padding(.vertical, 40)
    }

    // MARK: - Grouped Events

    private var groupedEvents: [Date: [DetectionEvent]] {
        Dictionary(grouping: dataManager.recentEvents.reversed()) { event in
            Calendar.current.startOfDay(for: event.timestamp)
        }
    }

    // MARK: - Actions

    private func exportAsJSON() {
        if let json = dataManager.exportEventsAsJSON() {
            exportData = json
            showShareSheet = true
        }
    }

    private func exportAsCSV() {
        exportData = dataManager.exportEventsAsCSV()
        showShareSheet = true
    }

    private func clearAllEvents() {
        dataManager.clearAllEvents()
    }

    // MARK: - Helpers

    private func formatSectionHeader(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

struct EventDetailRow: View {
    let event: DetectionEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatTime(event.timestamp))
                    .font(.headline)

                Spacer()

                confidenceBadge
            }

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Heart Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(event.heartRateAtDetection)) bpm")
                        .font(.body)
                        .fontWeight(.semibold)
                }

                if let baseline = event.baselineHeartRate {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Baseline")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(Int(baseline)) bpm")
                            .font(.body)
                    }
                }

                if let delta = event.deltaFromBaseline {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Delta")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("+\(Int(delta))")
                            .font(.body)
                            .foregroundColor(.orange)
                    }
                }
            }

            HStack {
                Label(event.detectionType.rawValue, systemImage: "waveform.path.ecg")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                responseLabel
            }
        }
        .padding(.vertical, 4)
    }

    private var confidenceBadge: some View {
        Text("\(Int(event.confidence * 100))%")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(confidenceColor.opacity(0.2))
            .foregroundColor(confidenceColor)
            .cornerRadius(8)
    }

    private var responseLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: responseIcon)
            Text(event.alertResponse.rawValue.capitalized)
        }
        .font(.caption)
        .foregroundColor(responseColor)
    }

    private var confidenceColor: Color {
        switch event.confidence {
        case 0.8...1.0:
            return .red
        case 0.5..<0.8:
            return .orange
        default:
            return .yellow
        }
    }

    private var responseIcon: String {
        switch event.alertResponse {
        case .acknowledged:
            return "checkmark.circle.fill"
        case .snoozed:
            return "moon.zzz.fill"
        case .dismissed:
            return "xmark.circle.fill"
        case .notResponded:
            return "bell.badge.fill"
        }
    }

    private var responseColor: Color {
        switch event.alertResponse {
        case .acknowledged:
            return .green
        case .snoozed:
            return .blue
        case .dismissed:
            return .gray
        case .notResponded:
            return .orange
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

// Share Sheet for exporting data
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct EventLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventLogView()
        }
    }
}
