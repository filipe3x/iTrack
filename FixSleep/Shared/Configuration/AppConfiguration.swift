//
//  AppConfiguration.swift
//  iTrack
//
//  Centralized configuration for detection thresholds and app behavior
//

import Foundation

/// Centralized configuration for all app constants and thresholds
struct AppConfiguration {

    // MARK: - Detection Thresholds

    /// Absolute heart rate threshold in BPM
    static var absoluteHRThreshold: Double = 80.0

    /// Relative heart rate delta threshold (BPM rise over time window)
    static var relativeHRDeltaThreshold: Double = 15.0

    /// Time window for relative delta detection (seconds)
    static var relativeHRDeltaTimeWindow: TimeInterval = 60.0

    /// HRV drop percentage threshold
    static var hrvDropThreshold: Double = 30.0

    /// Cooldown period between alerts (seconds) to prevent spam
    static var alertCooldownPeriod: TimeInterval = 300.0 // 5 minutes

    // MARK: - Sensitivity Presets

    enum SensitivityPreset: String, CaseIterable {
        case low
        case medium
        case high
        case custom

        var absoluteThreshold: Double {
            switch self {
            case .low: return 90.0
            case .medium: return 80.0
            case .high: return 70.0
            case .custom: return AppConfiguration.absoluteHRThreshold
            }
        }

        var relativeDelta: Double {
            switch self {
            case .low: return 20.0
            case .medium: return 15.0
            case .high: return 10.0
            case .custom: return AppConfiguration.relativeHRDeltaThreshold
            }
        }
    }

    // MARK: - Sampling Configuration

    /// Active detection sampling rate (samples per second)
    static var activeSamplingRate: TimeInterval = 1.0

    /// Stable state sampling rate (seconds between samples)
    static var stableSamplingRate: TimeInterval = 30.0

    /// Power saving mode sampling rate (seconds between samples)
    static var powerSavingSamplingRate: TimeInterval = 60.0

    /// Threshold to consider HR stable (consecutive stable readings needed)
    static var stableReadingsThreshold: Int = 10

    // MARK: - Sleep Window

    /// Default sleep window start time (22:00)
    static var defaultSleepStartHour: Int = 22
    static var defaultSleepStartMinute: Int = 0

    /// Default sleep window end time (07:00)
    static var defaultSleepEndHour: Int = 7
    static var defaultSleepEndMinute: Int = 0

    // MARK: - Battery & Performance

    /// Target maximum battery drain percentage overnight
    static let targetBatteryDrainPercent: Double = 10.0

    /// Enable power saving mode when battery below this percentage
    static var powerSavingBatteryThreshold: Double = 20.0

    // MARK: - Alert Configuration

    /// Enable haptic feedback for alerts
    static var enableHaptics: Bool = true

    /// Enable audible alarm for alerts
    static var enableAudibleAlarm: Bool = false

    /// Alert latency target (seconds)
    static let alertLatencyTarget: TimeInterval = 5.0

    // MARK: - Data Storage

    /// Maximum number of events to store locally
    static var maxStoredEvents: Int = 1000

    /// Data retention period (days)
    static var dataRetentionDays: Int = 30

    /// Enable CloudKit sync
    static var enableCloudKitSync: Bool = false

    // MARK: - Movement Filtering

    /// Accelerometer threshold for movement detection (g-force)
    static var movementThreshold: Double = 0.15

    /// Duration of movement to suppress false positives (seconds)
    static var movementSuppressionDuration: TimeInterval = 30.0

    // MARK: - ML Model Configuration

    /// Enable ML-based detection
    static var enableMLDetection: Bool = false

    /// Current ML model version
    static let mlModelVersion: String = "1.0.0"

    // MARK: - Testing & Debug

    /// Enable debug logging
    static var enableDebugLogging: Bool = false

    /// Target sensitivity for detection (percentage)
    static let targetSensitivity: Double = 80.0

    /// Target false positive rate (percentage)
    static let targetFalsePositiveRate: Double = 5.0
}
