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
    @Published var activationState: WCSessionActivationState = .notActivated
    @Published var lastHandshakeSucceeded: Bool?
    @Published var lastHandshakeError: String?

    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    private var activationRetryCount = 0
    private let maxActivationRetries = 5
    private var activationTimer: Timer?

    private override init() {
        super.init()
    }

    // MARK: - Activation

    func activate() {
        guard let session = session else {
            print("[WCManager-Watch] WatchConnectivity not supported")
            return
        }

        session.delegate = self

        print("[WCManager-Watch] Activating WCSession... (attempt \(activationRetryCount + 1))")
        print("[WCManager-Watch] isSupported: \(WCSession.isSupported())")

        if session.activationState == .notActivated {
            session.activate()
        } else {
            print("[WCManager-Watch] Session already activated with state: \(session.activationState.rawValue)")
            updateState(from: session)
        }
    }

    /// Start periodic activation attempts for simulator reliability
    func startActivationRetry() {
        stopActivationRetry()
        activationRetryCount = 0

        activationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.activationState == .activated && self.isiPhoneReachable {
                print("[WCManager-Watch] Connection established, stopping retry")
                self.stopActivationRetry()
                return
            }

            self.activationRetryCount += 1
            if self.activationRetryCount > self.maxActivationRetries {
                print("[WCManager-Watch] Max activation retries reached")
                self.stopActivationRetry()
                return
            }

            print("[WCManager-Watch] Retry activation attempt \(self.activationRetryCount)")
            self.activate()

            // Also probe if session is activated but not reachable
            if self.activationState == .activated {
                self.probeConnection()
            }
        }
    }

    func stopActivationRetry() {
        activationTimer?.invalidate()
        activationTimer = nil
    }

    /// Probe connection to iPhone
    func probeConnection() {
        guard let session = session, session.activationState == .activated else {
            print("[WCManager-Watch] Cannot probe: session not activated")
            return
        }

        print("[WCManager-Watch] Probing connection - isReachable: \(session.isReachable)")

        guard session.isReachable else {
            DispatchQueue.main.async {
                self.lastHandshakeSucceeded = false
                self.lastHandshakeError = "iPhone not reachable"
            }
            return
        }

        let payload: [String: Any] = [
            "type": "ping",
            "timestamp": Date().timeIntervalSince1970
        ]

        session.sendMessage(payload, replyHandler: { reply in
            print("[WCManager-Watch] ✓ Received pong from iPhone: \(reply)")
            DispatchQueue.main.async {
                self.lastHandshakeSucceeded = true
                self.lastHandshakeError = nil
                self.stopActivationRetry()
            }
        }, errorHandler: { error in
            print("[WCManager-Watch] ✗ Ping failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.lastHandshakeSucceeded = false
                self.lastHandshakeError = error.localizedDescription
            }
        })
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
        let stateNames = ["notActivated", "inactive", "activated"]
        let stateName = stateNames[min(activationState.rawValue, 2)]

        print("[WCManager-Watch] ===== ACTIVATION COMPLETE =====")
        print("[WCManager-Watch] State: \(stateName) (\(activationState.rawValue))")
        print("[WCManager-Watch] isCompanionAppInstalled: \(session.isCompanionAppInstalled)")
        print("[WCManager-Watch] isReachable: \(session.isReachable)")
        print("[WCManager-Watch] ==============================")

        DispatchQueue.main.async {
            self.activationState = activationState
            self.isiPhonePaired = self.isPaired(session)
            self.isiOSAppInstalled = self.isCompanionAppInstalled(session)
            self.isiPhoneReachable = session.isReachable
        }

        if let error = error {
            print("[WCManager-Watch] Activation error: \(error.localizedDescription)")
        } else if activationState == .activated {
            // Start retry mechanism to establish connection in simulators
            self.startActivationRetry()
            self.probeConnection()

            if session.isReachable {
                if let payload = latestHeartRatePayload() {
                    print("[WCManager-Watch] Sending initial heart rate to iPhone")
                    session.sendMessage(["type": "heartRate"].merging(payload) { $1 }, replyHandler: nil)
                }
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("[WCManager-Watch] ===== REACHABILITY CHANGED =====")
        print("[WCManager-Watch] isReachable: \(session.isReachable)")
        print("[WCManager-Watch] isCompanionAppInstalled: \(session.isCompanionAppInstalled)")
        print("[WCManager-Watch] ================================")

        DispatchQueue.main.async {
            self.isiPhonePaired = self.isPaired(session)
            self.isiOSAppInstalled = self.isCompanionAppInstalled(session)
            self.isiPhoneReachable = session.isReachable

            if session.isReachable {
                self.stopActivationRetry()

                if let payload = self.latestHeartRatePayload() {
                    print("[WCManager-Watch] Sending heart rate after becoming reachable")
                    session.sendMessage(["type": "heartRate"].merging(payload) { $1 }, replyHandler: nil)
                }
            }
        }
    }

    // MARK: - Receive Messages

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("[WCManager-Watch] didReceiveMessage (no reply): \(message)")
        handleReceivedMessage(message)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        print("[WCManager-Watch] didReceiveMessage (with reply): \(message)")

        if let type = message["type"] as? String {
            switch type {
            case "eventsRequest":
                print("[WCManager-Watch] Responding to eventsRequest")
                if let data = try? JSONEncoder().encode(DataManager.shared.loadAllEvents()) {
                    replyHandler(["events": data])
                } else {
                    replyHandler([:])
                }
                return
            case "ping":
                print("[WCManager-Watch] Responding to ping with pong")
                replyHandler([
                    "type": "pong",
                    "isMonitoring": HeartRateMonitor.shared.isMonitoring,
                    "timestamp": Date().timeIntervalSince1970
                ])
                // Mark successful handshake
                DispatchQueue.main.async {
                    self.lastHandshakeSucceeded = true
                    self.lastHandshakeError = nil
                    self.stopActivationRetry()
                }
                return
            case "statusRequest":
                print("[WCManager-Watch] Responding to statusRequest")
                replyHandler(["isMonitoring": HeartRateMonitor.shared.isMonitoring])
                return
            case "heartRateRequest":
                print("[WCManager-Watch] Responding to heartRateRequest")
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
        print("[WCManager-Watch] didReceiveUserInfo: \(userInfo)")
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
