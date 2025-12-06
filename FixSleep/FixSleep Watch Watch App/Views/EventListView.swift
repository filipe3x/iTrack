//
//  EventListView.swift
//  iTrack WatchKit Extension
//
//  List of detected events
//

import SwiftUI

struct EventListView: View {
    @StateObject private var dataManager = DataManager.shared

    var body: some View {
        List {
            if dataManager.recentEvents.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars")
                        .font(.largeTitle)
                        .foregroundColor(.gray)

                    Text("No Events")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("Events will appear here when detected")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(dataManager.recentEvents.reversed()) { event in
                    EventRow(event: event)
                }
            }
        }
        .navigationTitle("Events")
    }
}

struct EventRow: View {
    let event: DetectionEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(eventColor)
                    .font(.caption)

                Text("\(Int(event.heartRateAtDetection)) bpm")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Text(event.detectionType.rawValue)
                .font(.caption2)
                .foregroundColor(.gray)

            if let delta = event.deltaFromBaseline {
                Text("+\(Int(delta)) from baseline")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }

            // Response status
            responseIndicator
        }
        .padding(.vertical, 4)
    }

    private var eventColor: Color {
        switch event.confidence {
        case 0.8...1.0:
            return .red
        case 0.5..<0.8:
            return .orange
        default:
            return .yellow
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.timestamp)
    }

    private var responseIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: responseIcon)
                .font(.caption2)

            Text(event.alertResponse.rawValue.capitalized)
                .font(.caption2)
        }
        .foregroundColor(responseColor)
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
            return .yellow
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
