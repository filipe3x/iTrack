//
//  HeartRateData.swift
//  iTrack
//
//  Model for heart rate and HRV data
//

import Foundation

/// Represents a single heart rate sample
struct HeartRateSample: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let heartRate: Double // BPM
    let hrv: Double? // milliseconds (SDNN or RMSSD)
    let isMovement: Bool // Flag if accelerometer detected movement

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        heartRate: Double,
        hrv: Double? = nil,
        isMovement: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.hrv = hrv
        self.isMovement = isMovement
    }
}

/// Represents a collection of heart rate samples for analysis
struct HeartRateSession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var samples: [HeartRateSample]
    var detectedEvents: [DetectionEvent]

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        samples: [HeartRateSample] = [],
        detectedEvents: [DetectionEvent] = []
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.samples = samples
        self.detectedEvents = detectedEvents
    }

    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }

    var averageHeartRate: Double? {
        guard !samples.isEmpty else { return nil }
        return samples.map { $0.heartRate }.reduce(0, +) / Double(samples.count)
    }

    var maxHeartRate: Double? {
        samples.map { $0.heartRate }.max()
    }

    var minHeartRate: Double? {
        samples.map { $0.heartRate }.min()
    }
}

/// Movement data from accelerometer
struct MovementData: Codable {
    let timestamp: Date
    let magnitude: Double // Combined acceleration magnitude
    let isSignificant: Bool // Above movement threshold

    init(timestamp: Date, magnitude: Double, threshold: Double = AppConfiguration.movementThreshold) {
        self.timestamp = timestamp
        self.magnitude = magnitude
        self.isSignificant = magnitude > threshold
    }
}
