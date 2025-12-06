Apple Watch App to track heart pulses middle night
Specifications for Xcode (watchOS + iOS) implementation

- Target
    - watchOS 7+ watch app with iOS 14+ companion app support.
    - Support Apple Watch Series 4+ (optimize for devices with optical HR sensor).

- High-level behavior
    - Monitor heart rate continuously during user-defined "sleep window" (default: bedtime to wake time).
    - Detect nocturnal arousal events by analyzing heart rate and HRV trends (estimate arousal/cortisol-related activity; do not claim direct cortisol measurement).
    - Immediately notify the user on the watch when an event is detected using haptic + optional alarm sound.
    - Allow user to acknowledge/dismiss/snooze the alert on the watch.

- Data acquisition
    - Use HealthKit HKWorkoutSession or HKLiveWorkoutBuilder to access near-continuous heart rate samples while in sleep window.
    - Sample frequency: configurable (default 1 sample/sec while active detection; reduce to 5–30s when stable to save battery).
    - Collect HR and HRV (where available), and accelerometer data via CoreMotion for movement filtering.
    - Timestamp all samples and detected events.

- Detection logic
    - Implement configurable thresholds and adaptive detection:
        - Absolute HR threshold (bpm).
        - Relative delta threshold (e.g., HR rises > X bpm within Y seconds).
        - HRV drop pattern heuristics.
        - Optional machine-learning model hook for advanced detection (include model versioning).
    - Use accelerometer data to suppress false positives during movement artifacts.
    - Provide sensitivity presets (low/medium/high) and allow custom tuning.

- Notifications & haptics
    - Use WatchKit haptics (WKInterfaceDevice.current().play(.notification) or recommended watchOS API) and optional audible alarm.
    - Provide local notification fallback from companion iPhone when watch not worn.
    - Notification latency target: alert within 5 seconds of detection.

- UI & Settings
    - On-watch UI: current HR, recent events list, quick acknowledge/snooze, toggle monitoring, sensitivity presets.
    - iPhone settings: sleep window, thresholds, alarm preferences, export logs, HealthKit sync controls.
    - Provide onboarding explaining limitations (e.g., not a medical device) and permissions needed.

- Data storage & sync
    - Store raw samples and events locally (CoreData or lightweight file store).
    - Sync summaries and events to iPhone via WatchConnectivity.
    - Optional CloudKit export for user backup/analytics (user opt-in).
    - Write appropriate samples to HealthKit (workout/session + heart rate samples) only with user permission.

- Privacy & permissions
    - Request HealthKit read/write permissions with clear NSHealthShareUsageDescription/NSHealthUpdateUsageDescription and local privacy rationale.
    - Request motion access and notification permissions with Info.plist strings.
    - Comply with App Store privacy requirements; provide a privacy policy link.

- Background, battery & reliability
    - Use workout sessions to maintain continuous HR access during sleep window.
    - Implement power-saving mode: reduced sampling, lower detection sensitivity.
    - Log battery consumption metrics; target <10% additional battery drain overnight on typical devices.

- Edge cases & error handling
    - Handle sensor unavailability (no HR data) and notify user to wear the watch.
    - Debounce repeated alerts; implement per-event cooldown (configurable).
    - Gracefully handle connectivity loss between watch and phone.

- Testing & acceptance criteria
    - Unit tests for detection logic with synthetic HR/HRV traces.
    - Integration tests for session lifecycle and notifications.
    - Acceptance: correctly detect simulated arousal events with >80% sensitivity and <5% false positives in test data; alert delivered within 5s; data persisted and synced.

- Implementation notes & frameworks
    - Required frameworks: HealthKit, WatchKit, WatchConnectivity, CoreMotion, UserNotifications, CoreData/CloudKit (optional).
    - Provide example code snippets for starting HKWorkoutSession and subscribing to HKLiveWorkoutBuilder heart rate updates (developer to implement).
    - Include telemetry for event counts, false positive rate (opt-in).

- Documentation & deliverables
    - README with setup steps, permissions to grant, and testing instructions.
    - Configurable constants in a single file (thresholds, time windows, sampling rates).
    - Deliver unit/integration tests and a small demo dataset for verification.

Acceptance checklist to hand off: target OS versions, HealthKit permissions implemented, continuous HR during sleep window, detection algorithm with configurable thresholds, haptic+sound alert, local persistence + sync, privacy strings, unit/integration tests, battery usage report.
