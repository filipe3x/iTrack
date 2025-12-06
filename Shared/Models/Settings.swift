//
//  Settings.swift
//  iTrack
//
//  App settings model
//

import Foundation

/// User settings for the app
struct UserSettings: Codable {
    var sleepWindowStart: DateComponents
    var sleepWindowEnd: DateComponents

    var sensitivityPreset: AppConfiguration.SensitivityPreset
    var customAbsoluteThreshold: Double?
    var customRelativeDelta: Double?

    var enableHaptics: Bool
    var enableAudibleAlarm: Bool
    var enablePowerSavingMode: Bool

    var enableCloudSync: Bool
    var enableTelemetry: Bool

    var notificationsEnabled: Bool

    init() {
        // Default sleep window: 22:00 - 07:00
        self.sleepWindowStart = DateComponents(
            hour: AppConfiguration.defaultSleepStartHour,
            minute: AppConfiguration.defaultSleepStartMinute
        )
        self.sleepWindowEnd = DateComponents(
            hour: AppConfiguration.defaultSleepEndHour,
            minute: AppConfiguration.defaultSleepEndMinute
        )

        self.sensitivityPreset = .medium
        self.customAbsoluteThreshold = nil
        self.customRelativeDelta = nil

        self.enableHaptics = AppConfiguration.enableHaptics
        self.enableAudibleAlarm = AppConfiguration.enableAudibleAlarm
        self.enablePowerSavingMode = false

        self.enableCloudSync = AppConfiguration.enableCloudKitSync
        self.enableTelemetry = false

        self.notificationsEnabled = true
    }

    /// Get the effective absolute threshold based on preset or custom value
    var effectiveAbsoluteThreshold: Double {
        if sensitivityPreset == .custom, let custom = customAbsoluteThreshold {
            return custom
        }
        return sensitivityPreset.absoluteThreshold
    }

    /// Get the effective relative delta based on preset or custom value
    var effectiveRelativeDelta: Double {
        if sensitivityPreset == .custom, let custom = customRelativeDelta {
            return custom
        }
        return sensitivityPreset.relativeDelta
    }

    /// Check if current time is within sleep window
    func isWithinSleepWindow(date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)

        guard let currentHour = components.hour,
              let currentMinute = components.minute,
              let startHour = sleepWindowStart.hour,
              let startMinute = sleepWindowStart.minute,
              let endHour = sleepWindowEnd.hour,
              let endMinute = sleepWindowEnd.minute else {
            return false
        }

        let currentMinutes = currentHour * 60 + currentMinute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute

        // Handle overnight window (e.g., 22:00 to 07:00)
        if startMinutes > endMinutes {
            return currentMinutes >= startMinutes || currentMinutes <= endMinutes
        } else {
            return currentMinutes >= startMinutes && currentMinutes <= endMinutes
        }
    }
}
