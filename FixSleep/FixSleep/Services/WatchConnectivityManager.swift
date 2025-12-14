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

    @Published var isSupported = WCSession.isSupported()
    @Published var isPaired = false
    @Published var isWatchAppInstalled = false
    @Published var isReachable = false
    @Published var activationState: WCSessionActivationState = .notActivated
    @Published var lastStatusCheck: Date?
    @Published var lastHandshakeSucceeded: Bool?
    @Published var lastHandshakeError: String?
    @Published var latestHeartRate: Double?
    @Published var latestHeartRateTimestamp: Date?
    @Published var watchIsMonitoring: Bool = false

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
            print("[WCManager-iOS] WatchConnectivity not supported on this device")
            return
        }

        // Set delegate immediately (not async) to catch early callbacks
        session.delegate = self

        print("[WCManager-iOS] Activating WCSession... (attempt \(activationRetryCount + 1))")
        print("[WCManager-iOS] isSupported: \(WCSession.isSupported())")

        if session.activationState == .notActivated {
            session.activate()
        } else {
            print("[WCManager-iOS] Session already activated with state: \(session.activationState.rawValue)")
            updateState(from: session)
        }
    }

    /// Start periodic activation attempts for simulator reliability
    func startActivationRetry() {
        stopActivationRetry()
        activationRetryCount = 0

        activationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.activationState == .activated && self.isReachable {
                print("[WCManager-iOS] Connection established, stopping retry")
                self.stopActivationRetry()
                return
            }

            self.activationRetryCount += 1
            if self.activationRetryCount > self.maxActivationRetries {
                print("[WCManager-iOS] Max activation retries reached")
                self.stopActivationRetry()
                return
            }

            print("[WCManager-iOS] Retry activation attempt \(self.activationRetryCount)")
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

    /// Ensures the WCSession is activated before attempting to use it.
    private func readySession() -> WCSession? {
        guard let session = session else { return nil }

        if session.activationState != .activated {
            activate()
            return nil
        }

        return session
    }

    private func updateState(from session: WCSession) {
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
            self.activationState = session.activationState
            self.lastStatusCheck = Date()
        }
    }

    /// Attempts to reach the watch and records whether we heard back.
    func probeConnection() {
        print("[WCManager-iOS] Probing connection...")

        guard let session = readySession() else {
            print("[WCManager-iOS] Probe failed: session not ready")
            DispatchQueue.main.async {
                self.lastHandshakeSucceeded = false
                self.lastHandshakeError = "WatchConnectivity não está disponível neste dispositivo."
                self.lastStatusCheck = Date()
            }
            return
        }
        updateState(from: session)

        print("[WCManager-iOS] Session state - isPaired: \(session.isPaired), isWatchAppInstalled: \(session.isWatchAppInstalled), isReachable: \(session.isReachable)")

        guard session.isReachable else {
            print("[WCManager-iOS] Probe failed: watch not reachable")
            DispatchQueue.main.async {
                self.lastHandshakeSucceeded = false
                self.lastHandshakeError = "Abra o FixSleep no Apple Watch para ligar."
                self.lastStatusCheck = Date()
            }
            return
        }

        let payload: [String: Any] = [
            "type": "ping",
            "timestamp": Date().timeIntervalSince1970
        ]

        print("[WCManager-iOS] Sending ping to watch...")

        session.sendMessage(
            payload,
            replyHandler: { reply in
                print("[WCManager-iOS] ✓ Received pong from watch: \(reply)")
                DispatchQueue.main.async {
                    self.lastHandshakeSucceeded = true
                    self.lastHandshakeError = nil
                    self.lastStatusCheck = Date()
                    self.stopActivationRetry()

                    if let isMonitoring = reply["isMonitoring"] as? Bool {
                        self.watchIsMonitoring = isMonitoring
                        print("[WCManager-iOS] Watch monitoring: \(isMonitoring)")
                    }
                }
            },
            errorHandler: { error in
                print("[WCManager-iOS] ✗ Ping failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.lastHandshakeSucceeded = false
                    self.lastHandshakeError = error.localizedDescription
                    self.lastStatusCheck = Date()
                }
            }
        )
    }

    // MARK: - Send Data to Watch

    /// Send settings to watch
    func sendSettings(_ settings: UserSettings) {
        guard let session = readySession(), session.isReachable else {
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
        guard let session = readySession() else { return }

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
        guard let session = readySession() else { return }
        session.transferUserInfo(info)
    }

    // MARK: - Request Data from Watch

    /// Request current monitoring status from watch
    func requestMonitoringStatus(completion: @escaping (Bool) -> Void) {
        guard let session = readySession(), session.isReachable else {
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
        guard let session = readySession(), session.isReachable else {
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

    // MARK: - Process Received Data

    private func processReceivedEvents(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let events = try decoder.decode([DetectionEvent].self, from: data)

            // Merge with existing events
            for event in events {
                let existingEvents = DataManager.shared.loadAllEvents()
                if !existingEvents.contains(where: { $0.id == event.id }) {
                    DataManager.shared.saveEvent(event)
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
            DataManager.shared.saveSettings(settings)
        } catch {
            print("Failed to decode settings: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let stateNames = ["notActivated", "inactive", "activated"]
        let stateName = stateNames[min(activationState.rawValue, 2)]

        print("[WCManager-iOS] ===== ACTIVATION COMPLETE =====")
        print("[WCManager-iOS] State: \(stateName) (\(activationState.rawValue))")
        print("[WCManager-iOS] isPaired: \(session.isPaired)")
        print("[WCManager-iOS] isWatchAppInstalled: \(session.isWatchAppInstalled)")
        print("[WCManager-iOS] isReachable: \(session.isReachable)")
        print("[WCManager-iOS] ==============================")

        updateState(from: session)
        DispatchQueue.main.async {
            self.activationState = activationState
        }

        if let error = error {
            print("[WCManager-iOS] Activation error: \(error.localizedDescription)")
        } else if activationState == .activated {
            // Start retry mechanism to establish connection in simulators
            self.startActivationRetry()
            self.probeConnection()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("[WCManager-iOS] Session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("[WCManager-iOS] Session deactivated - reactivating...")
        // Reactivate session for iOS
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("[WCManager-iOS] ===== REACHABILITY CHANGED =====")
        print("[WCManager-iOS] isReachable: \(session.isReachable)")
        print("[WCManager-iOS] isPaired: \(session.isPaired)")
        print("[WCManager-iOS] isWatchAppInstalled: \(session.isWatchAppInstalled)")
        print("[WCManager-iOS] ================================")

        updateState(from: session)

        // If we became reachable, stop retry and probe
        if session.isReachable {
            stopActivationRetry()
            probeConnection()
        }
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        print("[WCManager-iOS] Watch state changed - isPaired: \(session.isPaired), isWatchAppInstalled: \(session.isWatchAppInstalled)")
        updateState(from: session)
    }

    // MARK: - Receive Messages

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("[WCManager-iOS] didReceiveMessage (no reply): \(message)")
        handleReceivedMessage(message)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("[WCManager-iOS] didReceiveMessage (with reply): \(message)")

        // Handle messages that need specific replies
        if let type = message["type"] as? String {
            switch type {
            case "settingsRequest":
                // Watch is requesting latest settings
                let settings = DataManager.shared.settings
                if let data = try? JSONEncoder().encode(settings) {
                    replyHandler(["data": data])
                } else {
                    replyHandler([:])
                }
                return

            case "ping":
                // Watch is probing connection
                replyHandler([
                    "type": "pong",
                    "timestamp": Date().timeIntervalSince1970
                ])
                return

            default:
                break
            }
        }

        handleReceivedMessage(message)
        replyHandler(["status": "received"])
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("[WCManager-iOS] didReceiveUserInfo: \(userInfo)")
        handleReceivedMessage(userInfo)
    }

    private func handleReceivedMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else {
            print("[WCManager-iOS] Received message without type: \(message)")
            return
        }

        print("[WCManager-iOS] Handling message type: \(type)")

        switch type {
        case "event":
            // Received new event from watch
            if let eventData = message["data"] as? Data {
                processReceivedEvents(eventData)
            }

        case "events":
            // Received events batch from watch
            if let eventsData = message["data"] as? Data {
                processReceivedEvents(eventsData)
            }

        case "settings":
            // Received updated settings from watch
            if let settingsData = message["data"] as? Data {
                processReceivedSettings(settingsData)
            }

        case "heartRate":
            // Received heart rate update from watch
            if let bpm = message["bpm"] as? Double {
                let timestamp: Date
                if let ts = message["timestamp"] as? TimeInterval {
                    timestamp = Date(timeIntervalSince1970: ts)
                } else {
                    timestamp = Date()
                }
                DispatchQueue.main.async {
                    self.latestHeartRate = bpm
                    self.latestHeartRateTimestamp = timestamp
                }
                print("[WCManager-iOS] Received heart rate: \(bpm) bpm")
            }

        case "statusUpdate":
            // Received monitoring status update
            if let isMonitoring = message["isMonitoring"] as? Bool {
                DispatchQueue.main.async {
                    self.watchIsMonitoring = isMonitoring
                }
                print("[WCManager-iOS] Watch monitoring status: \(isMonitoring)")
            }

        case "pong":
            // Response to our ping
            print("[WCManager-iOS] Received pong from watch")
            if let isMonitoring = message["isMonitoring"] as? Bool {
                DispatchQueue.main.async {
                    self.watchIsMonitoring = isMonitoring
                }
            }

        default:
            print("[WCManager-iOS] Unknown message type: \(type)")
        }
    }

    /// Request current heart rate from watch
    func requestCurrentHeartRate() {
        guard let session = readySession(), session.isReachable else {
            print("[WCManager-iOS] Watch not reachable for heart rate request")
            return
        }

        let message = ["type": "heartRateRequest"]

        session.sendMessage(message, replyHandler: { reply in
            if let bpm = reply["bpm"] as? Double {
                let timestamp: Date
                if let ts = reply["timestamp"] as? TimeInterval {
                    timestamp = Date(timeIntervalSince1970: ts)
                } else {
                    timestamp = Date()
                }
                DispatchQueue.main.async {
                    self.latestHeartRate = bpm
                    self.latestHeartRateTimestamp = timestamp
                }
                print("[WCManager-iOS] Received heart rate reply: \(bpm) bpm")
            }
        }) { error in
            print("[WCManager-iOS] Failed to request heart rate: \(error.localizedDescription)")
        }
    }
}
