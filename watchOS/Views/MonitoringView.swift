//
//  MonitoringView.swift
//  iTrack WatchKit Extension
//
//  Main monitoring interface
//

import SwiftUI

struct MonitoringView: View {
    @StateObject private var heartRateMonitor = HeartRateMonitor.shared
    @StateObject private var dataManager = DataManager.shared
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 10) {
            // Current heart rate display
            VStack(spacing: 4) {
                Text("Heart Rate")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(heartRateMonitor.currentHeartRate))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(heartRateColor)

                    Text("BPM")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // HRV display (if available)
            if let hrv = heartRateMonitor.currentHRV {
                HStack(spacing: 4) {
                    Text("HRV:")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("\(Int(hrv)) ms")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }

            // Status indicator
            statusIndicator

            // Main action button
            Button(action: toggleMonitoring) {
                Text(heartRateMonitor.isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(heartRateMonitor.isMonitoring ? .red : .green)

            // Session info
            if heartRateMonitor.isMonitoring {
                sessionInfo
            }
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private var statusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(heartRateMonitor.isMonitoring ? Color.green : Color.gray)
                .frame(width: 8, height: 8)

            Text(heartRateMonitor.isMonitoring ? "Monitoring" : "Inactive")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    private var sessionInfo: some View {
        VStack(spacing: 4) {
            if let stats = heartRateMonitor.getStatistics() {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Min")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(Int(stats.min))")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .center, spacing: 2) {
                        Text("Avg")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(Int(stats.avg))")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Max")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(Int(stats.max))")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                .font(.system(.caption, design: .rounded))
            }

            if let session = dataManager.currentSession {
                Text("Events: \(session.detectedEvents.count)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 8)
    }

    private var heartRateColor: Color {
        let hr = heartRateMonitor.currentHeartRate
        if hr > dataManager.settings.effectiveAbsoluteThreshold {
            return .red
        } else if hr > dataManager.settings.effectiveAbsoluteThreshold * 0.8 {
            return .orange
        } else {
            return .green
        }
    }

    private func toggleMonitoring() {
        if heartRateMonitor.isMonitoring {
            Task {
                await heartRateMonitor.stopMonitoring()
            }
        } else {
            Task {
                do {
                    try await heartRateMonitor.startMonitoring()
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct MonitoringView_Previews: PreviewProvider {
    static var previews: some View {
        MonitoringView()
    }
}
