//
//  DetectionEngine.swift
//  iTrack WatchKit Extension
//
//  Detection algorithm for arousal events
//

import Foundation
import CoreMotion
import Combine

/// Analyzes heart rate data to detect arousal events
class DetectionEngine: ObservableObject {
    static let shared = DetectionEngine()

    @Published var lastDetectionTime: Date?

    private var motionManager = CMMotionManager()
    private var recentMovementData: [MovementData] = []

    private let movementBufferSize = 30

    private init() {
        setupMotionTracking()
    }

    // MARK: - Motion Tracking

    private func setupMotionTracking() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }

        motionManager.accelerometerUpdateInterval = 1.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }

            // Calculate magnitude
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let magnitude = sqrt(x*x + y*y + z*z)

            let movementData = MovementData(
                timestamp: Date(),
                magnitude: magnitude
            )

            self.recentMovementData.append(movementData)

            if self.recentMovementData.count > self.movementBufferSize {
                self.recentMovementData.removeFirst()
            }
        }
    }

    /// Check if there's significant movement in recent data
    private func hasRecentMovement() -> Bool {
        let cutoffTime = Date().addingTimeInterval(-AppConfiguration.movementSuppressionDuration)

        return recentMovementData.contains { movement in
            movement.timestamp > cutoffTime && movement.isSignificant
        }
    }

    // MARK: - Detection Logic

    /// Analyze a new heart rate sample for arousal detection
    func analyzeSample(_ sample: HeartRateSample, historicalData: [HeartRateSample]) {
        guard !historicalData.isEmpty else { return }

        let settings = DataManager.shared.settings

        // Check if we're in sleep window
        guard settings.isWithinSleepWindow() else { return }

        // Check cooldown period
        if let lastDetection = lastDetectionTime {
            let timeSinceLastAlert = Date().timeIntervalSince(lastDetection)
            if timeSinceLastAlert < AppConfiguration.alertCooldownPeriod {
                return // Still in cooldown
            }
        }

        // Suppress if movement detected
        let movementDetected = hasRecentMovement()
        if movementDetected && !AppConfiguration.enableDebugLogging {
            return // Skip detection during movement
        }

        // Calculate baseline
        let baseline = calculateBaseline(from: historicalData)

        // Run detection algorithms
        var detectionEvent: DetectionEvent?

        // 1. Absolute threshold detection
        if let event = checkAbsoluteThreshold(sample: sample, baseline: baseline) {
            detectionEvent = event
        }

        // 2. Relative delta detection
        if detectionEvent == nil,
           let event = checkRelativeDelta(sample: sample, historicalData: historicalData, baseline: baseline) {
            detectionEvent = event
        }

        // 3. HRV drop detection (if HRV available)
        if detectionEvent == nil,
           let event = checkHRVDrop(sample: sample, historicalData: historicalData) {
            detectionEvent = event
        }

        // If detection occurred, trigger alert
        if var event = detectionEvent {
            event.wasMovementSuppressed = movementDetected

            triggerAlert(for: event)
        }
    }

    // MARK: - Detection Algorithms

    /// Calculate baseline heart rate from historical data
    private func calculateBaseline(from data: [HeartRateSample]) -> Double {
        let recentSamples = Array(data.prefix(30))
        guard !recentSamples.isEmpty else { return 0 }

        let sum = recentSamples.map { $0.heartRate }.reduce(0, +)
        return sum / Double(recentSamples.count)
    }

    /// Check if absolute HR threshold is exceeded
    private func checkAbsoluteThreshold(sample: HeartRateSample, baseline: Double) -> DetectionEvent? {
        let settings = DataManager.shared.settings
        let threshold = settings.effectiveAbsoluteThreshold

        if sample.heartRate > threshold {
            return DetectionEvent(
                timestamp: sample.timestamp,
                detectionType: .absoluteHR,
                heartRateAtDetection: sample.heartRate,
                baselineHeartRate: baseline,
                hrvAtDetection: sample.hrv,
                confidence: min(1.0, (sample.heartRate - threshold) / threshold),
                deltaFromBaseline: sample.heartRate - baseline
            )
        }

        return nil
    }

    /// Check if relative HR delta threshold is exceeded
    private func checkRelativeDelta(
        sample: HeartRateSample,
        historicalData: [HeartRateSample],
        baseline: Double
    ) -> DetectionEvent? {
        let settings = DataManager.shared.settings
        let deltaThreshold = settings.effectiveRelativeDelta
        let timeWindow = AppConfiguration.relativeHRDeltaTimeWindow

        // Get samples within time window
        let cutoffTime = sample.timestamp.addingTimeInterval(-timeWindow)
        let recentSamples = historicalData.filter { $0.timestamp > cutoffTime }

        guard !recentSamples.isEmpty else { return nil }

        // Find minimum HR in window
        let minHR = recentSamples.map { $0.heartRate }.min() ?? baseline

        // Calculate delta
        let delta = sample.heartRate - minHR

        if delta > deltaThreshold {
            return DetectionEvent(
                timestamp: sample.timestamp,
                detectionType: .relativeDelta,
                heartRateAtDetection: sample.heartRate,
                baselineHeartRate: baseline,
                hrvAtDetection: sample.hrv,
                confidence: min(1.0, delta / deltaThreshold),
                deltaFromBaseline: sample.heartRate - baseline,
                timeWindow: timeWindow
            )
        }

        return nil
    }

    /// Check if HRV drop pattern is detected
    private func checkHRVDrop(sample: HeartRateSample, historicalData: [HeartRateSample]) -> DetectionEvent? {
        guard let currentHRV = sample.hrv else { return nil }

        // Get recent samples with HRV
        let samplesWithHRV = historicalData.filter { $0.hrv != nil }
        guard samplesWithHRV.count >= 5 else { return nil }

        // Calculate baseline HRV
        let recentHRVSamples = Array(samplesWithHRV.prefix(10))
        let baselineHRV = recentHRVSamples.compactMap { $0.hrv }.reduce(0, +) / Double(recentHRVSamples.count)

        // Calculate drop percentage
        let dropPercentage = ((baselineHRV - currentHRV) / baselineHRV) * 100

        if dropPercentage > AppConfiguration.hrvDropThreshold {
            return DetectionEvent(
                timestamp: sample.timestamp,
                detectionType: .hrvDrop,
                heartRateAtDetection: sample.heartRate,
                baselineHeartRate: nil,
                hrvAtDetection: currentHRV,
                confidence: min(1.0, dropPercentage / AppConfiguration.hrvDropThreshold)
            )
        }

        return nil
    }

    // MARK: - Alert Triggering

    private func triggerAlert(for event: DetectionEvent) {
        // Update last detection time
        lastDetectionTime = event.timestamp

        // Save event
        DataManager.shared.saveEvent(event)
        DataManager.shared.addEventToSession(event)

        // Trigger haptic and notification
        HapticManager.shared.triggerAlert(for: event)

        // Log for debugging
        if AppConfiguration.enableDebugLogging {
            print("🚨 Detection event: \(event.detectionType.rawValue)")
            print("   HR: \(event.heartRateAtDetection) bpm")
            print("   Baseline: \(event.baselineHeartRate ?? 0) bpm")
            print("   Confidence: \(event.confidence)")
        }
    }

    // MARK: - Manual Testing

    /// Inject a test detection event (for testing)
    func injectTestEvent() {
        let event = DetectionEvent(
            timestamp: Date(),
            detectionType: .absoluteHR,
            heartRateAtDetection: 95.0,
            baselineHeartRate: 65.0,
            confidence: 0.9,
            deltaFromBaseline: 30.0
        )

        triggerAlert(for: event)
    }
}
