//
//  EventListView.swift
//  iTrack WatchKit Extension
//
//  List of detected events
//

import SwiftUI

struct EventListView: View {
    @ObservedObject private var dataManager = DataManager.shared

    var body: some View {
        List {
            if dataManager.recentEvents.isEmpty {
                VStack(spacing: 12) {
                    if #available(watchOS 8.0, *) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(AppTheme.Gradients.moon)
                    } else {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.Accent.moon)
                    }

                    Text("Sem Eventos")
                        .font(AppTheme.Typography.caption(weight: .medium))
                        .foregroundColor(AppTheme.Text.primary)

                    Text("Eventos detetados aparecerão aqui")
                        .font(AppTheme.Typography.tiny())
                        .foregroundColor(AppTheme.Text.muted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .listRowBackground(Color.clear)
            } else {
                ForEach(dataManager.recentEvents.reversed()) { event in
                    EventRow(event: event)
                        .listRowBackground(Color.white.opacity(0.02))
                }
            }
        }
        .navigationTitle("Events")
    }
}

struct EventRow: View {
    let event: DetectionEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(eventColor)
                    .font(.system(size: 12))

                Text("\(Int(event.heartRateAtDetection)) bpm")
                    .font(AppTheme.Typography.caption(weight: .semibold))
                    .foregroundColor(AppTheme.Text.primary)

                Spacer()

                Text(timeString)
                    .font(AppTheme.Typography.tiny())
                    .foregroundColor(AppTheme.Text.muted)
            }

            Text(event.detectionType.rawValue)
                .font(AppTheme.Typography.tiny())
                .foregroundColor(AppTheme.Text.secondary)

            if let delta = event.deltaFromBaseline {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Accent.chamomile)

                    Text("+\(Int(delta)) da baseline")
                        .font(AppTheme.Typography.tiny())
                        .foregroundColor(AppTheme.Accent.chamomile)
                }
            }

            // Response status
            responseIndicator
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }

    private var eventColor: Color {
        switch event.confidence {
        case 0.8...1.0:
            return AppTheme.Accent.rose
        case 0.5..<0.8:
            return AppTheme.Accent.chamomile
        default:
            return AppTheme.Accent.lavender
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
                .font(.system(size: 10))

            Text(responseText)
                .font(AppTheme.Typography.tiny(weight: .medium))
        }
        .foregroundColor(responseColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(responseColor.opacity(0.12))
        .cornerRadius(4)
    }

    private var responseText: String {
        switch event.alertResponse {
        case .acknowledged:
            return "Acknowledged"
        case .snoozed:
            return "Snoozed"
        case .dismissed:
            return "Dismissed"
        case .notResponded:
            return "Not Responded"
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
            return AppTheme.Accent.mint
        case .snoozed:
            return AppTheme.Accent.lavender
        case .dismissed:
            return AppTheme.Text.muted
        case .notResponded:
            return AppTheme.Accent.chamomile
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
