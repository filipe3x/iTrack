//
//  Event.swift
//  iTrack
//
//  Model for arousal detection events
//

import Foundation

/// Type of detection that triggered the event
enum DetectionType: String, Codable, CaseIterable {
    case absoluteHR = "Absolute HR Threshold"
    case relativeDelta = "Relative HR Delta"
    case hrvDrop = "HRV Drop"
    case mlModel = "ML Model Detection"
    case combined = "Combined Detection"
}

/// User response to an alert
enum AlertResponse: String, Codable {
    case acknowledged
    case snoozed
    case dismissed
    case notResponded
}

/// Represents a detected arousal event
struct DetectionEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let detectionType: DetectionType
    let heartRateAtDetection: Double
    let baselineHeartRate: Double?
    let hrvAtDetection: Double?
    let confidence: Double // 0.0 to 1.0

    var alertResponse: AlertResponse
    var responseTime: Date?
    var notes: String?

    // Detection context
    let deltaFromBaseline: Double?
    let timeWindow: TimeInterval?
    var wasMovementSuppressed: Bool

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        detectionType: DetectionType,
        heartRateAtDetection: Double,
        baselineHeartRate: Double? = nil,
        hrvAtDetection: Double? = nil,
        confidence: Double = 1.0,
        alertResponse: AlertResponse = .notResponded,
        responseTime: Date? = nil,
        notes: String? = nil,
        deltaFromBaseline: Double? = nil,
        timeWindow: TimeInterval? = nil,
        wasMovementSuppressed: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.detectionType = detectionType
        self.heartRateAtDetection = heartRateAtDetection
        self.baselineHeartRate = baselineHeartRate
        self.hrvAtDetection = hrvAtDetection
        self.confidence = confidence
        self.alertResponse = alertResponse
        self.responseTime = responseTime
        self.notes = notes
        self.deltaFromBaseline = deltaFromBaseline
        self.timeWindow = timeWindow
        self.wasMovementSuppressed = wasMovementSuppressed
    }

    var wasAcknowledged: Bool {
        alertResponse == .acknowledged || alertResponse == .snoozed
    }
}

/// Summary statistics for a night's monitoring
struct NightSummary: Codable, Identifiable {
    let id: UUID
    let date: Date
    let monitoringStartTime: Date
    let monitoringEndTime: Date
    let totalEvents: Int
    let averageHeartRate: Double
    let maxHeartRate: Double
    let minHeartRate: Double
    let averageHRV: Double?
    let events: [DetectionEvent]

    var duration: TimeInterval {
        monitoringEndTime.timeIntervalSince(monitoringStartTime)
    }

    var acknowledgedEvents: Int {
        events.filter { $0.wasAcknowledged }.count
    }
}
