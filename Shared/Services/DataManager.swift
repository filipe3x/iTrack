//
//  DataManager.swift
//  iTrack
//
//  Manages local data persistence and sync
//

import Foundation
import Combine

#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

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
    func saveSettings(_ settings: UserSettings, shouldSync: Bool = true) {
        self.settings = settings

        if let encoded = try? encoder.encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }

        // Sync to watch/phone via WatchConnectivity
        if shouldSync {
            syncSettings()
        }
    }

    /// Update a specific setting
    func updateSettings(_ update: (inout UserSettings) -> Void) {
        var updatedSettings = settings
        update(&updatedSettings)
        saveSettings(updatedSettings)
    }

    // MARK: - Event Management

    /// Save a detection event
    func saveEvent(_ event: DetectionEvent, shouldSync: Bool = true) {
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

        if shouldSync {
            syncEvents()
        }
    }

    /// Update an existing event
    func updateEvent(_ event: DetectionEvent, shouldSync: Bool = true) {
        var events = loadAllEvents()

        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event

            if let encoded = try? encoder.encode(events) {
                userDefaults.set(encoded, forKey: eventsKey)
            }

            loadEvents()

            if shouldSync {
                syncEvents()
            }
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
    func startSession(mealTiming: MealTiming? = nil) {
        let session = HeartRateSession(startTime: Date(), mealTiming: mealTiming)
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
        #if canImport(WatchConnectivity)
        guard let encodedSettings = try? encoder.encode(settings) else { return }
        WatchSyncBridge.send(type: "settings", payload: encodedSettings)
        #endif
    }

    private func syncEvents() {
        #if canImport(WatchConnectivity)
        guard let encodedEvents = try? encoder.encode(loadAllEvents()) else { return }
        WatchSyncBridge.send(type: "events", payload: encodedEvents)
        #endif
    }
}

#if canImport(WatchConnectivity)
private enum WatchSyncBridge {
    private static let delegate = WatchSyncDelegate()

    static func send(type: String, payload: Data) {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        if session.delegate == nil {
            session.delegate = delegate
            session.activate()
        }

        let message: [String: Any] = [
            "type": type,
            "data": payload
        ]

        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send \(type) payload: \(error.localizedDescription)")
            }
        } else {
            session.transferUserInfo(message)
        }
    }
}

private final class WatchSyncDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
#endif
