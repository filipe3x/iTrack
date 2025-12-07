//
//  AppIcons.swift
//  iTrack
//
//  SF Symbol icon mappings matching website iconography
//

import SwiftUI

/// Centralized icon definitions matching website's visual language
struct AppIcons {

    // MARK: - Core App Icons

    /// Main app icon - moon representing sleep tracking
    static let app = "moon.stars.fill"

    /// Sleep/night mode
    static let sleep = "moon.fill"

    /// Moon with zzz (sleeping)
    static let sleeping = "moon.zzz.fill"

    /// Sunrise (wake up)
    static let wake = "sunrise.fill"

    // MARK: - Monitoring & Health

    /// Heart rate monitoring
    static let heartRate = "heart.fill"

    /// Heart rate waveform
    static let waveform = "waveform.path.ecg"

    /// Activity/motion detection
    static let activity = "figure.walk"

    /// Alert/arousal event
    static let alert = "exclamationmark.triangle.fill"

    /// Warning indicator
    static let warning = "exclamationmark.circle.fill"

    /// Success/checkmark
    static let success = "checkmark.circle.fill"

    // MARK: - Time & Schedule

    /// Clock/time
    static let time = "clock.fill"

    /// Timer/countdown
    static let timer = "timer"

    /// Schedule/calendar
    static let schedule = "calendar"

    /// Bell (notifications)
    static let bell = "bell.fill"

    // MARK: - Controls

    /// Play/start monitoring
    static let play = "play.fill"

    /// Pause monitoring
    static let pause = "pause.fill"

    /// Stop monitoring
    static let stop = "stop.fill"

    /// Settings/gear
    static let settings = "gearshape.fill"

    // MARK: - Data & Analytics

    /// Chart/statistics
    static let chart = "chart.xyaxis.line"

    /// List/log
    static let list = "list.bullet"

    /// Info/information
    static let info = "info.circle.fill"

    /// Export/share
    static let export = "square.and.arrow.up"

    // MARK: - Sleep Protocol Icons (matching website)

    /// Chamomile tea (sun/warmth)
    static let chamomile = "sun.max.fill"

    /// Lavender (sparkles/calm)
    static let lavender = "sparkles"

    /// Magnesium/supplements (pills)
    static let supplement = "pills.fill"

    /// Breathing exercise
    static let breathing = "wind"

    /// Temperature control
    static let temperature = "thermometer.medium"

    /// Environment/home
    static let environment = "house.fill"

    // MARK: - States & Conditions

    /// Active/monitoring state
    static let active = "circle.fill"

    /// Inactive/off state
    static let inactive = "circle"

    /// Battery/power
    static let battery = "battery.100"

    /// Connection status
    static let connected = "wifi"

    /// Disconnected
    static let disconnected = "wifi.slash"

    // MARK: - watchOS Specific

    /// Haptic feedback
    static let haptic = "hand.tap.fill"

    /// Watch device
    static let watch = "applewatch"

    /// iPhone device
    static let phone = "iphone"

    // MARK: - Helper Functions

    /// Get icon for event severity
    static func iconForSeverity(_ severity: EventSeverity) -> String {
        switch severity {
        case .low:
            return "circle.fill"
        case .medium:
            return "exclamationmark.circle.fill"
        case .high:
            return "exclamationmark.triangle.fill"
        }
    }

    /// Get color for event severity
    static func colorForSeverity(_ severity: EventSeverity) -> Color {
        switch severity {
        case .low:
            return AppTheme.Accent.mint
        case .medium:
            return AppTheme.Accent.chamomile
        case .high:
            return AppTheme.Accent.rose
        }
    }

    /// Get icon for monitoring state
    static func iconForMonitoringState(_ isActive: Bool) -> String {
        isActive ? play : pause
    }

    /// Get color for monitoring state
    static func colorForMonitoringState(_ isActive: Bool) -> Color {
        isActive ? AppTheme.Accent.mint : AppTheme.Text.muted
    }
}

// MARK: - Event Severity Enum

enum EventSeverity: String, Codable {
    case low
    case medium
    case high
}

// MARK: - Icon View Helper

/// Helper view for displaying themed icons
struct ThemedIcon: View {
    let icon: String
    let size: CGFloat
    let color: Color
    let gradient: Bool

    init(
        _ icon: String,
        size: CGFloat = 20,
        color: Color = AppTheme.Accent.lavender,
        gradient: Bool = false
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.gradient = gradient
    }

    var body: some View {
        Group {
            if gradient {
                if #available(watchOS 8.0, iOS 15.0, *) {
                    Image(systemName: icon)
                        .font(.system(size: size, weight: .light))
                        .foregroundStyle(AppTheme.Gradients.moon)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: size, weight: .light))
                        .foregroundColor(AppTheme.Accent.mint)
                }
            } else {
                Image(systemName: icon)
                    .font(.system(size: size, weight: .light))
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AppIcons_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                // Core icons
                IconSection(title: "Core App") {
                    IconPreview(AppIcons.app, "App", color: AppTheme.Accent.lavender)
                    IconPreview(AppIcons.sleep, "Sleep", color: AppTheme.Accent.moon)
                    IconPreview(AppIcons.sleeping, "Sleeping", color: AppTheme.Accent.lavender)
                    IconPreview(AppIcons.wake, "Wake", color: AppTheme.Accent.chamomile)
                }

                // Monitoring
                IconSection(title: "Monitoring") {
                    IconPreview(AppIcons.heartRate, "Heart Rate", color: AppTheme.Accent.rose)
                    IconPreview(AppIcons.waveform, "Waveform", color: AppTheme.Accent.mint)
                    IconPreview(AppIcons.alert, "Alert", color: AppTheme.Accent.rose)
                    IconPreview(AppIcons.success, "Success", color: AppTheme.Accent.mint)
                }

                // Protocol icons
                IconSection(title: "Sleep Protocol") {
                    IconPreview(AppIcons.chamomile, "Chamomile", color: AppTheme.Accent.chamomile)
                    IconPreview(AppIcons.lavender, "Lavender", color: AppTheme.Accent.lavender)
                    IconPreview(AppIcons.breathing, "Breathing", color: AppTheme.Accent.moon)
                    IconPreview(AppIcons.temperature, "Temperature", color: AppTheme.Accent.mint)
                }

                // Controls
                IconSection(title: "Controls") {
                    IconPreview(AppIcons.play, "Play", color: AppTheme.Accent.mint)
                    IconPreview(AppIcons.pause, "Pause", color: AppTheme.Accent.chamomile)
                    IconPreview(AppIcons.stop, "Stop", color: AppTheme.Accent.rose)
                    IconPreview(AppIcons.settings, "Settings", color: AppTheme.Text.secondary)
                }
            }
            .padding()
        }
        .background(AppTheme.Background.deep)
    }

    struct IconSection<Content: View>: View {
        let title: String
        let content: Content

        init(title: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                if #available(watchOS 9.0, iOS 16.0, *) {
                    Text(title)
                        .font(AppTheme.Typography.subtitle(weight: .medium))
                        .foregroundColor(AppTheme.Text.secondary)
                        .textCase(.uppercase)
                        .tracking(1.2)
                } else {
                    Text(title)
                        .font(AppTheme.Typography.subtitle(weight: .medium))
                        .foregroundColor(AppTheme.Text.secondary)
                        .textCase(.uppercase)
                }

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppTheme.Spacing.lg) {
                    content
                }
            }
        }
    }

    struct IconPreview: View {
        let icon: String
        let label: String
        let color: Color

        init(_ icon: String, _ label: String, color: Color) {
            self.icon = icon
            self.label = label
            self.color = color
        }

        var body: some View {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                    .frame(width: 60, height: 60)
                    .background(color.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.md)

                Text(label)
                    .font(AppTheme.Typography.tiny())
                    .foregroundColor(AppTheme.Text.muted)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
#endif
