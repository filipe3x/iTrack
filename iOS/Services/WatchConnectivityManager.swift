//
//  WatchConnectivityManager.swift
//  iTrack
//
//  Manages communication between iPhone and Apple Watch
//

import Foundation
import WatchConnectivity
import Combine

/// Manages WatchConnectivity session for syncing data between iPhone and Watch
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var isWatchAppInstalled = false
    @Published var isReachable = false
    @Published var latestHeartRate: Double?
    @Published var latestHeartRateTimestamp: Date?

    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    private override init() {
        super.init()
    }

    // MARK: - Activation

    func activate() {
        guard let session = session else {
            print("WatchConnectivity not supported")
            return
        }

        session.delegate = self
        updateState(from: session)
        session.activate()
    }

    private func updateState(from session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable

            if session.isReachable {
                self.requestCurrentHeartRate()
            }
        }
    }

    // MARK: - Send Data to Watch

    /// Send settings to watch
    func sendSettings(_ settings: UserSettings) {
        guard let session = session, session.isReachable else {
            print("Watch not reachable")
            return
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)

            let message: [String: Any] = [
                "type": "settings",
                "data": data
            ]

            session.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send settings: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to encode settings: \(error.localizedDescription)")
        }
    }

    /// Send full event history to watch
    func sendEventsData(_ data: Data) {
        guard let session = session else { return }

        let message: [String: Any] = [
            "type": "events",
            "data": data
        ]

        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send events: \(error.localizedDescription)")
            }
        } else {
            session.transferUserInfo(message)
        }
    }

    /// Transfer user info (for background sync)
    func transferUserInfo(_ info: [String: Any]) {
        guard let session = session else { return }
        session.transferUserInfo(info)
    }

    // MARK: - Request Data from Watch

    /// Request current monitoring status from watch
    func requestMonitoringStatus(completion: @escaping (Bool) -> Void) {
        guard let session = session, session.isReachable else {
            completion(false)
            return
        }

        let message = ["type": "statusRequest"]

        session.sendMessage(message, replyHandler: { reply in
            if let isMonitoring = reply["isMonitoring"] as? Bool {
                completion(isMonitoring)
            } else {
                completion(false)
            }
        }) { error in
            print("Failed to request status: \(error.localizedDescription)")
            completion(false)
        }
    }

    /// Request recent events from watch
    func requestRecentEvents() {
        guard let session = session, session.isReachable else {
            print("Watch not reachable")
            return
        }

        let message = ["type": "eventsRequest"]

        session.sendMessage(message, replyHandler: { reply in
            if let eventsData = reply["events"] as? Data {
                self.processReceivedEvents(eventsData)
            }
        }) { error in
            print("Failed to request events: \(error.localizedDescription)")
        }
    }

    /// Request the latest heart rate sample from the watch
    func requestCurrentHeartRate() {
        guard let session = session, session.isReachable else { return }

        let message = ["type": "heartRateRequest"]

        session.sendMessage(message, replyHandler: { reply in
            if let bpm = reply["bpm"] as? Double {
                let timestamp = reply["timestamp"] as? TimeInterval
                self.updateHeartRate(bpm: bpm, timestamp: timestamp)
            }
        }) { error in
            print("Failed to request heart rate: \(error.localizedDescription)")
        }
    }

    // MARK: - Process Received Data

    private func processReceivedEvents(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let events = try decoder.decode([DetectionEvent].self, from: data)

            // Merge with existing events
            for event in events {
                let existingEvents = DataManager.shared.loadAllEvents()
                if !existingEvents.contains(where: { $0.id == event.id }) {
                    DataManager.shared.saveEvent(event, shouldSync: false)
                }
            }
        } catch {
            print("Failed to decode events: \(error.localizedDescription)")
        }
    }

    private func processReceivedSettings(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let settings = try decoder.decode(UserSettings.self, from: data)
            DataManager.shared.saveSettings(settings, shouldSync: false)
        } catch {
            print("Failed to decode settings: \(error.localizedDescription)")
        }
    }

    private func updateHeartRate(bpm: Double, timestamp: TimeInterval?) {
        let date = timestamp.map { Date(timeIntervalSince1970: $0) }

        DispatchQueue.main.async {
            self.latestHeartRate = bpm
            self.latestHeartRateTimestamp = date
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        updateState(from: session)

        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")

            if session.isReachable {
                requestCurrentHeartRate()
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        // Reactivate session for iOS
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        updateState(from: session)
        print("Watch reachability changed: \(session.isReachable)")
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        updateState(from: session)
    }

    // MARK: - Receive Messages

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleReceivedMessage(message)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let type = message["type"] as? String {
            switch type {
            case "eventsRequest":
                if let data = try? JSONEncoder().encode(DataManager.shared.loadAllEvents()) {
                    replyHandler(["events": data])
                } else {
                    replyHandler([:])
                }
                return
            case "statusRequest":
                replyHandler(["isMonitoring": false])
                return
            case "settingsRequest":
                if let data = try? JSONEncoder().encode(DataManager.shared.settings) {
                    replyHandler(["data": data])
                } else {
                    replyHandler([:])
                }
                return
            case "heartRate":
                if let bpm = message["bpm"] as? Double {
                    let timestamp = message["timestamp"] as? TimeInterval
                    updateHeartRate(bpm: bpm, timestamp: timestamp)
                }
                replyHandler(["status": "received"])
                return
            default:
                break
            }
        }

        handleReceivedMessage(message)

        // Send acknowledgement
        replyHandler(["status": "received"])
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleReceivedMessage(userInfo)
    }

    private func handleReceivedMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }

        switch type {
        case "event":
            // Received new event from watch
            if let eventData = message["data"] as? Data {
                processReceivedEvents(eventData)
            }

        case "settings":
            // Received updated settings from watch
            if let settingsData = message["data"] as? Data {
                processReceivedSettings(settingsData)
            }

        case "statusUpdate":
            // Received monitoring status update
            if let isMonitoring = message["isMonitoring"] as? Bool {
                print("Watch monitoring status: \(isMonitoring)")
            }

        case "events":
            // Received a full events sync
            if let eventsData = message["data"] as? Data {
                processReceivedEvents(eventsData)
            }

        case "heartRate":
            if let bpm = message["bpm"] as? Double {
                let timestamp = message["timestamp"] as? TimeInterval
                updateHeartRate(bpm: bpm, timestamp: timestamp)
            }

        default:
            print("Unknown message type: \(type)")
        }
    }
}
