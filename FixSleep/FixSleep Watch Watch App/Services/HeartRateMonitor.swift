//
//  HeartRateMonitor.swift
//  iTrack WatchKit Extension
//
//  Manages continuous heart rate monitoring using HealthKit workout sessions
//

import Foundation
import HealthKit
import Combine

/// Monitors heart rate continuously during sleep window
class HeartRateMonitor: NSObject, ObservableObject {
    static let shared = HeartRateMonitor()

    @Published var isMonitoring = false
    @Published var currentHeartRate: Double = 0
    @Published var currentHRV: Double?
    @Published var lastSampleTime: Date?

    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private let healthStore = HealthKitManager.shared.getHealthStore()

    private var samplingTimer: Timer?
    private var currentSamplingRate: TimeInterval = AppConfiguration.activeSamplingRate

    private var heartRateBuffer: [HeartRateSample] = []
    private let bufferSize = 60 // Keep last 60 samples for analysis

    override private init() {
        super.init()
    }

    // MARK: - Monitoring Control

    /// Start continuous heart rate monitoring
    func startMonitoring(mealTiming: MealTiming? = nil) async throws {
        guard !isMonitoring else { return }

        // Request HealthKit authorization if needed
        if !HealthKitManager.shared.isAuthorized {
            try await HealthKitManager.shared.requestAuthorization()
        }

        // Create workout configuration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor

        // Create workout session
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()

            // Set data source
            builder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )

            // Set delegates
            session.delegate = self
            builder.delegate = self

            self.workoutSession = session
            self.workoutBuilder = builder

            // Start session and builder
            let startDate = Date()
            session.startActivity(with: startDate)
            try await builder.beginCollection(at: startDate)

            await MainActor.run {
                self.isMonitoring = true
                DataManager.shared.startSession(mealTiming: mealTiming)
            }

            print("Heart rate monitoring started")
        } catch {
            print("Failed to start workout session: \(error.localizedDescription)")
            throw error
        }
    }

    /// Stop continuous heart rate monitoring
    func stopMonitoring() async {
        guard isMonitoring else { return }

        samplingTimer?.invalidate()
        samplingTimer = nil

        if let session = workoutSession {
            session.end()
        }

        if let builder = workoutBuilder {
            do {
                try await builder.endCollection(at: Date())
                _ = try await builder.finishWorkout()
            } catch {
                print("Error ending workout: \(error.localizedDescription)")
            }
        }

        await MainActor.run {
            self.isMonitoring = false
            self.workoutSession = nil
            self.workoutBuilder = nil
            DataManager.shared.endSession()
        }

        print("Heart rate monitoring stopped")
    }

    // MARK: - Sampling Rate Management

    /// Adjust sampling rate based on HR stability
    func adjustSamplingRate(isStable: Bool) {
        if isStable {
            currentSamplingRate = AppConfiguration.stableSamplingRate
        } else {
            currentSamplingRate = AppConfiguration.activeSamplingRate
        }
    }

    /// Enable power saving mode
    func enablePowerSavingMode(_ enabled: Bool) {
        if enabled {
            currentSamplingRate = AppConfiguration.powerSavingSamplingRate
        } else {
            currentSamplingRate = AppConfiguration.activeSamplingRate
        }
    }

    // MARK: - Data Processing

    /// Process new heart rate sample
    private func processSample(_ sample: HeartRateSample) {
        // Add to buffer
        heartRateBuffer.append(sample)
        if heartRateBuffer.count > bufferSize {
            heartRateBuffer.removeFirst()
        }

        // Save to current session
        DataManager.shared.addSample(sample)

        // Update published properties
        DispatchQueue.main.async {
            self.currentHeartRate = sample.heartRate
            self.lastSampleTime = sample.timestamp
        }

        // Send to detection engine
        DetectionEngine.shared.analyzeSample(sample, historicalData: heartRateBuffer)
    }

    /// Get baseline heart rate from recent samples
    func getBaselineHeartRate() -> Double? {
        guard heartRateBuffer.count >= 10 else { return nil }

        let recentSamples = Array(heartRateBuffer.prefix(30))
        let sum = recentSamples.map { $0.heartRate }.reduce(0, +)
        return sum / Double(recentSamples.count)
    }

    /// Get heart rate statistics
    func getStatistics() -> (min: Double, max: Double, avg: Double)? {
        guard !heartRateBuffer.isEmpty else { return nil }

        let heartRates = heartRateBuffer.map { $0.heartRate }
        let min = heartRates.min() ?? 0
        let max = heartRates.max() ?? 0
        let avg = heartRates.reduce(0, +) / Double(heartRates.count)

        return (min, max, avg)
    }

    /// Clear buffer (for testing)
    func clearBuffer() {
        heartRateBuffer.removeAll()
    }
}

// MARK: - HKWorkoutSessionDelegate

extension HeartRateMonitor: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        print("Workout session state changed: \(fromState.rawValue) -> \(toState.rawValue)")

        if toState == .ended {
            Task {
                await stopMonitoring()
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")

        Task {
            await stopMonitoring()
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension HeartRateMonitor: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        // Process collected data
        for type in collectedTypes {
            if type == HKQuantityType.quantityType(forIdentifier: .heartRate),
               let quantityType = type as? HKQuantityType {
                processHeartRateStatistics(workoutBuilder.statistics(for: quantityType))
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events if needed
    }

    private func processHeartRateStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics,
              let quantity = statistics.mostRecentQuantity() else {
            return
        }

        let bpm = quantity.doubleValue(for: HKUnit(from: "count/min"))

        let sample = HeartRateSample(
            timestamp: statistics.endDate,
            heartRate: bpm
        )

        processSample(sample)
    }
}
