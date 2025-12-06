//
//  HealthKitManager.swift
//  iTrack
//
//  Manages HealthKit access and data reading/writing
//

import Foundation
import HealthKit

/// Manages all HealthKit interactions for the app
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false

    // MARK: - HealthKit Types

    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)

    private let typesToRead: Set<HKObjectType> = {
        var types: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]

        if let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(hrvType)
        }

        return types
    }()

    private let typesToWrite: Set<HKSampleType> = {
        var types: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]

        if let workoutType = HKObjectType.workoutType() as? HKSampleType {
            types.insert(workoutType)
        }

        return types
    }()

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// Request HealthKit authorization
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
        await MainActor.run {
            self.isAuthorized = true
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            isAuthorized = false
            return
        }

        let status = healthStore.authorizationStatus(for: heartRateType)
        isAuthorized = status == .sharingAuthorized
    }

    // MARK: - Heart Rate Queries

    /// Fetch recent heart rate samples
    func fetchRecentHeartRateSamples(
        limit: Int = 100,
        completion: @escaping (Result<[HeartRateSample], Error>) -> Void
    ) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: limit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let quantitySamples = samples as? [HKQuantitySample] else {
                completion(.success([]))
                return
            }

            let heartRateSamples = quantitySamples.map { sample -> HeartRateSample in
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                return HeartRateSample(
                    timestamp: sample.endDate,
                    heartRate: bpm
                )
            }

            completion(.success(heartRateSamples))
        }

        healthStore.execute(query)
    }

    /// Fetch HRV samples for a given time range
    func fetchHRVSamples(
        from startDate: Date,
        to endDate: Date,
        completion: @escaping (Result<[(Date, Double)], Error>) -> Void
    ) {
        guard let hrvType = hrvType else {
            completion(.success([]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)

        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let quantitySamples = samples as? [HKQuantitySample] else {
                completion(.success([]))
                return
            }

            let hrvSamples = quantitySamples.map { sample -> (Date, Double) in
                let ms = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                return (sample.endDate, ms)
            }

            completion(.success(hrvSamples))
        }

        healthStore.execute(query)
    }

    // MARK: - Write Data

    /// Save a heart rate sample to HealthKit
    func saveHeartRateSample(_ sample: HeartRateSample) async throws {
        let quantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: sample.heartRate)

        let quantitySample = HKQuantitySample(
            type: heartRateType,
            quantity: quantity,
            start: sample.timestamp,
            end: sample.timestamp
        )

        try await healthStore.save(quantitySample)
    }

    /// Get HealthStore for workout sessions (used by HeartRateMonitor)
    func getHealthStore() -> HKHealthStore {
        return healthStore
    }
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case queryFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit authorization required"
        case .queryFailed:
            return "Failed to query HealthKit data"
        }
    }
}
