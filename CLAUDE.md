# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iTrack is a watchOS 7+ and iOS 14+ app that monitors heart rate during sleep to detect nocturnal arousal events. The system analyzes HR and HRV trends to estimate arousal/cortisol-related activity and immediately notifies users via haptic and optional audible alerts.

**Target devices:** Apple Watch Series 4+ with optical HR sensor

## Core Architecture

The app consists of two components:

1. **watchOS App** - Primary interface and data collection
   - Continuous HR monitoring during user-defined sleep window
   - Real-time detection and alerting
   - Local data storage and display

2. **iOS Companion App** - Configuration and data management
   - Settings interface (sleep window, thresholds, alarm preferences)
   - Event log viewing and export
   - Fallback notifications when watch not worn

### Key Technical Components

**Data Flow:**
- HealthKit (HKWorkoutSession/HKLiveWorkoutBuilder) → HR/HRV samples
- CoreMotion → Accelerometer data for movement filtering
- Detection algorithm → Event detection
- WatchKit haptics + UserNotifications → Alerts
- WatchConnectivity → Sync between watch and phone
- CoreData/local storage → Persistence
- Optional CloudKit → User backup/analytics

**Detection Logic:**
- Configurable thresholds: absolute HR (bpm), relative delta (bpm rise over time), HRV drop patterns
- Accelerometer-based false positive suppression
- Sensitivity presets (low/medium/high) + custom tuning
- Optional ML model hook for advanced detection (include model versioning)
- Target: >80% sensitivity, <5% false positives, <5s alert latency

**Power Management:**
- Use workout sessions for continuous HR access during sleep window
- Adaptive sampling: 1 sample/sec during active detection, 5-30s when stable
- Power-saving mode with reduced sampling/sensitivity
- Target: <10% additional battery drain overnight

## Development Requirements

### Required Frameworks
- HealthKit - Heart rate and HRV data access
- WatchKit - Watch UI and haptics
- WatchConnectivity - Watch-phone sync
- CoreMotion - Movement detection
- UserNotifications - Alert delivery
- CoreData or lightweight file store for persistence
- CloudKit (optional) - Cloud backup

### Permissions Required
Must include Info.plist strings for:
- `NSHealthShareUsageDescription` - Reading heart rate data
- `NSHealthUpdateUsageDescription` - Writing workout sessions
- Motion access permissions
- Notification permissions
- Privacy policy link for App Store compliance

## Implementation Guidelines

**Configuration Management:**
- Centralize all configurable constants (thresholds, time windows, sampling rates) in a single file
- Make settings adjustable from iPhone app

**Testing Strategy:**
- Unit tests for detection logic with synthetic HR/HRV traces
- Integration tests for session lifecycle and notifications
- Simulate arousal events with test data to validate detection accuracy

**Edge Cases to Handle:**
- Sensor unavailability (prompt user to wear watch)
- Connectivity loss between watch and phone
- Debounce repeated alerts with per-event cooldown
- Battery-saving fallbacks when power is low

**Privacy & Compliance:**
- Request HealthKit permissions with clear rationale
- Include disclaimer that app is not a medical device
- Implement opt-in for telemetry and cloud sync
- Comply with App Store privacy requirements

## Acceptance Criteria

Before considering implementation complete:
- [ ] Target OS versions supported (watchOS 7+, iOS 14+)
- [ ] HealthKit permissions properly implemented
- [ ] Continuous HR monitoring during sleep window
- [ ] Detection algorithm with configurable thresholds
- [ ] Haptic + sound alerts functioning
- [ ] Local persistence + watch-phone sync working
- [ ] All privacy strings in Info.plist
- [ ] Unit and integration tests passing
- [ ] Battery usage <10% overnight
- [ ] Alert latency <5 seconds
- [ ] Detection accuracy: >80% sensitivity, <5% false positives on test data
