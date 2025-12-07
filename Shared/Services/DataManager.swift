//
//  DataManager.swift
//  iTrack
//
//  Manages local data persistence and sync
//

import Foundation
import Combine

/// Manages persistent storage of events, sessions, and settings
class DataManager: ObservableObject {
    static let shared = DataManager()

    @Published var settings: UserSettings
    @Published var recentEvents: [DetectionEvent] = []
    @Published var currentSession: HeartRateSession?

    private let settingsKey = "userSettings"
    private let eventsKey = "detectionEvents"
    private let sessionsKey = "heartRateSessions"

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        // Load settings
        if let data = userDefaults.data(forKey: settingsKey),
           let settings = try? decoder.decode(UserSettings.self, from: data) {
            self.settings = settings
        } else {
            self.settings = UserSettings()
        }

        // Load recent events
        loadEvents()
    }

    // MARK: - Settings Management

    /// Save user settings
    func saveSettings(_ settings: UserSettings) {
        self.settings = settings

        if let encoded = try? encoder.encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }

        // Sync to watch/phone via WatchConnectivity
        syncSettings()
    }

    /// Update a specific setting
    func updateSettings(_ update: (inout UserSettings) -> Void) {
        var updatedSettings = settings
        update(&updatedSettings)
        saveSettings(updatedSettings)
    }

    // MARK: - Event Management

    /// Save a detection event
    func saveEvent(_ event: DetectionEvent) {
        var events = loadAllEvents()
        events.append(event)

        // Enforce maximum storage limit
        if events.count > AppConfiguration.maxStoredEvents {
            events = Array(events.suffix(AppConfiguration.maxStoredEvents))
        }

        // Clean old events based on retention policy
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -AppConfiguration.dataRetentionDays,
            to: Date()
        ) ?? Date()

        events = events.filter { $0.timestamp > cutoffDate }

        if let encoded = try? encoder.encode(events) {
            userDefaults.set(encoded, forKey: eventsKey)
        }

        loadEvents()
        syncEvents()
    }

    /// Update an existing event
    func updateEvent(_ event: DetectionEvent) {
        var events = loadAllEvents()

        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event

            if let encoded = try? encoder.encode(events) {
                userDefaults.set(encoded, forKey: eventsKey)
            }

            loadEvents()
            syncEvents()
        }
    }

    /// Load recent events
    private func loadEvents() {
        recentEvents = Array(loadAllEvents().suffix(50))
    }

    /// Load all stored events
    func loadAllEvents() -> [DetectionEvent] {
        guard let data = userDefaults.data(forKey: eventsKey),
              let events = try? decoder.decode([DetectionEvent].self, from: data) else {
            return []
        }
        return events
    }

    /// Get events for a specific date range
    func getEvents(from startDate: Date, to endDate: Date) -> [DetectionEvent] {
        return loadAllEvents().filter {
            $0.timestamp >= startDate && $0.timestamp <= endDate
        }
    }

    /// Delete an event
    func deleteEvent(_ event: DetectionEvent) {
        var events = loadAllEvents()
        events.removeAll { $0.id == event.id }

        if let encoded = try? encoder.encode(events) {
            userDefaults.set(encoded, forKey: eventsKey)
        }

        loadEvents()
        syncEvents()
    }

    /// Clear all events
    func clearAllEvents() {
        userDefaults.removeObject(forKey: eventsKey)
        recentEvents = []
        syncEvents()
    }

    // MARK: - Session Management

    /// Start a new monitoring session
    func startSession() {
        let session = HeartRateSession(startTime: Date())
        currentSession = session
    }

    /// Add sample to current session
    func addSample(_ sample: HeartRateSample) {
        guard var session = currentSession else { return }
        session.samples.append(sample)
        currentSession = session
    }

    /// Add detected event to current session
    func addEventToSession(_ event: DetectionEvent) {
        guard var session = currentSession else { return }
        session.detectedEvents.append(event)
        currentSession = session
    }

    /// End current monitoring session
    func endSession() {
        guard var session = currentSession else { return }
        session.endTime = Date()

        // Save session
        var sessions = loadAllSessions()
        sessions.append(session)

        if let encoded = try? encoder.encode(sessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }

        currentSession = nil
    }

    /// Load all stored sessions
    private func loadAllSessions() -> [HeartRateSession] {
        guard let data = userDefaults.data(forKey: sessionsKey),
              let sessions = try? decoder.decode([HeartRateSession].self, from: data) else {
            return []
        }
        return sessions
    }

    // MARK: - Data Export

    /// Export events as JSON
    func exportEventsAsJSON() -> String? {
        let events = loadAllEvents()
        guard let data = try? encoder.encode(events),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }
        return json
    }

    /// Export events as CSV
    func exportEventsAsCSV() -> String {
        let events = loadAllEvents()
        var csv = "ID,Timestamp,Type,HeartRate,Baseline,HRV,Confidence,Response,Delta,MovementSuppressed\n"

        let dateFormatter = ISO8601DateFormatter()

        for event in events {
            // Break up the complex expression into separate steps
            let id = event.id.uuidString
            let timestamp = dateFormatter.string(from: event.timestamp)
            let type = event.detectionType.rawValue
            let heartRate = String(event.heartRateAtDetection)
            let baseline = event.baselineHeartRate.map { String($0) } ?? ""
            let hrv = event.hrvAtDetection.map { String($0) } ?? ""
            let confidence = String(event.confidence)
            let response = event.alertResponse.rawValue
            let delta = event.deltaFromBaseline.map { String($0) } ?? ""
            let movement = String(event.wasMovementSuppressed)

            let fields: [String] = [id, timestamp, type, heartRate, baseline, hrv, confidence, response, delta, movement]
            let row = fields.map { "\"\($0)\"" }.joined(separator: ",")

            csv += row + "\n"
        }

        return csv
    }

    // MARK: - Sync (placeholder for WatchConnectivity)

    private func syncSettings() {
        // Will be implemented in WatchConnectivityManager
    }

    private func syncEvents() {
        // Will be implemented in WatchConnectivityManager
    }
}
