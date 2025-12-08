//
//  WatchConnectivityManager.swift
//  FixSleep Watch Watch App
//
//  Manages communication between Apple Watch and iPhone
//

import Foundation
import WatchConnectivity
import Combine

/// Manages WatchConnectivity session for syncing data between Watch and iPhone
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var isiPhoneReachable = false
    @Published var lastSentHeartRate: Double?
    @Published var lastSentTimestamp: Date?
    @Published var isiPhonePaired = false
    @Published var isiOSAppInstalled = false

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
        session.activate()
    }

    // MARK: - Send Data to iPhone

    private func canSend(to session: WCSession?) -> WCSession? {
        guard let session else { return nil }

        guard isActivated(session) else {
            print("WCSession cannot send: session not activated yet")
            return nil
        }

        guard isPaired(session) else {
            print("WCSession cannot send: iPhone not paired")
            return nil
        }

        if !isCompanionAppInstalled(session) {
            // In some setups the flag can be false even when the iOS app is present (e.g. during dev).
            print("WCSession warning: iOS app reported as not installed; attempting to send anyway")
        }

        return session
    }

    /// Send settings to iPhone
    func sendSettings(_ settings: UserSettings) {
        guard let session = canSend(to: session) else { return }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)

            let message: [String: Any] = [
                "type": "settings",
                "data": data
            ]

            if session.isReachable {
                session.sendMessage(message, replyHandler: nil) { error in
                    print("Failed to send settings to iPhone: \(error.localizedDescription)")
                }
            } else {
                session.transferUserInfo(message)
            }
        } catch {
            print("Failed to encode settings: \(error.localizedDescription)")
        }
    }

    /// Send the latest events to the paired iPhone
    func sendEventsData(_ data: Data) {
        guard let session = canSend(to: session) else { return }

        let message: [String: Any] = [
            "type": "events",
            "data": data
        ]

        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send events to iPhone: \(error.localizedDescription)")
            }
        } else {
            session.transferUserInfo(message)
        }
    }

    /// Send the most recent heart rate sample to the paired iPhone
    func sendHeartRate(_ bpm: Double, at timestamp: Date) {
        guard let session = canSend(to: session), session.isReachable else { return }

        let message: [String: Any] = [
            "type": "heartRate",
            "bpm": bpm,
            "timestamp": timestamp.timeIntervalSince1970
        ]

        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send heart rate to iPhone: \(error.localizedDescription)")
        }

        DispatchQueue.main.async {
            self.lastSentHeartRate = bpm
            self.lastSentTimestamp = timestamp
        }
    }

    // MARK: - Requests

    /// Request the latest settings from iPhone
    func requestSettings(completion: @escaping (UserSettings?) -> Void) {
        guard let session = canSend(to: session), session.isReachable else {
            completion(nil)
            return
        }

        let message = ["type": "settingsRequest"]

        session.sendMessage(message, replyHandler: { reply in
            if let data = reply["data"] as? Data {
                let decoder = JSONDecoder()
                let settings = try? decoder.decode(UserSettings.self, from: data)
                completion(settings)
            } else {
                completion(nil)
            }
        }) { error in
            print("Failed to request settings: \(error.localizedDescription)")
            completion(nil)
        }
    }

    /// Generate the most recent heart rate payload if available
    private func latestHeartRatePayload() -> [String: Any]? {
        let bpm = HeartRateMonitor.shared.currentHeartRate
        let timestamp = HeartRateMonitor.shared.lastSampleTime

        guard bpm > 0, let timestamp else { return nil }

        return [
            "bpm": bpm,
            "timestamp": timestamp.timeIntervalSince1970
        ]
    }

    // MARK: - Process Received Data

    private func processReceivedEvents(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let events = try decoder.decode([DetectionEvent].self, from: data)

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

    private func updateState(from session: WCSession) {
        DispatchQueue.main.async {
            self.isiPhonePaired = self.isPaired(session)
            self.isiOSAppInstalled = self.isCompanionAppInstalled(session)
            self.isiPhoneReachable = session.isReachable
        }
    }

    private func isActivated(_ session: WCSession) -> Bool {
        #if os(watchOS)
        return session.activationState == .activated
        #else
        return true
        #endif
    }

    private func isPaired(_ session: WCSession) -> Bool {
        #if os(watchOS)
        // watchOS does not expose WCSession.isPaired; if we're running on watchOS the watch is already paired.
        return true
        #else
        return session.isPaired
        #endif
    }

    private func isCompanionAppInstalled(_ session: WCSession) -> Bool {
        #if os(watchOS)
        return session.isCompanionAppInstalled
        #else
        return session.isWatchAppInstalled || session.isCompanionAppInstalled
        #endif
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isiPhonePaired = self.isPaired(session)
            self.isiOSAppInstalled = self.isCompanionAppInstalled(session)
            self.isiPhoneReachable = session.isReachable
        }

        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")

            if session.isReachable {
                if let payload = latestHeartRatePayload() {
                    session.sendMessage(["type": "heartRate"].merging(payload) { $1 }, replyHandler: nil)
                }
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isiPhonePaired = self.isPaired(session)
            self.isiOSAppInstalled = self.isCompanionAppInstalled(session)
            self.isiPhoneReachable = session.isReachable
            print("iPhone reachability changed: \(session.isReachable)")

            if session.isReachable, let payload = self.latestHeartRatePayload() {
                session.sendMessage(["type": "heartRate"].merging(payload) { $1 }, replyHandler: nil)
            }
        }
    }

    // MARK: - Receive Messages

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleReceivedMessage(message)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        if let type = message["type"] as? String {
            switch type {
            case "eventsRequest":
                if let data = try? JSONEncoder().encode(DataManager.shared.loadAllEvents()) {
                    replyHandler(["events": data])
                } else {
                    replyHandler([:])
                }
                return
            case "ping":
                replyHandler([
                    "type": "pong",
                    "isMonitoring": HeartRateMonitor.shared.isMonitoring,
                    "timestamp": Date().timeIntervalSince1970
                ])
                return
            case "statusRequest":
                replyHandler(["isMonitoring": HeartRateMonitor.shared.isMonitoring])
                return
            case "heartRateRequest":
                if let payload = latestHeartRatePayload() {
                    replyHandler(payload)
                } else {
                    replyHandler([:])
                }
                return
            default:
                break
            }
        }

        handleReceivedMessage(message)
        replyHandler(["status": "received"])
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleReceivedMessage(userInfo)
    }

    private func handleReceivedMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }

        switch type {
        case "event":
            if let eventData = message["data"] as? Data {
                processReceivedEvents(eventData)
            }

        case "settings":
            if let settingsData = message["data"] as? Data {
                processReceivedSettings(settingsData)
            }

        case "events":
            if let eventsData = message["data"] as? Data {
                processReceivedEvents(eventsData)
            }

        default:
            print("Unknown message type: \(type)")
        }
    }
}
