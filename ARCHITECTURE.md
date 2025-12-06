# iTrack - Architecture Documentation

## System Architecture Overview

iTrack is a dual-platform application consisting of a watchOS app for continuous heart rate monitoring and an iOS companion app for configuration and data management.

## Core Components

### 1. Data Layer

#### Models (`Shared/Models/`)

**HeartRateData.swift**
- `HeartRateSample`: Individual HR/HRV reading with timestamp
- `HeartRateSession`: Collection of samples for a monitoring session
- `MovementData`: Accelerometer data for false positive filtering

**Event.swift**
- `DetectionEvent`: Represents an arousal detection with metadata
- `DetectionType`: Enum for different detection algorithms
- `AlertResponse`: User response to alerts
- `NightSummary`: Aggregated statistics for a night's monitoring

**Settings.swift**
- `UserSettings`: User-configurable preferences
- Sleep window configuration
- Sensitivity presets and thresholds
- Alert preferences

#### Services (`Shared/Services/`)

**HealthKitManager**
- Singleton managing all HealthKit interactions
- Authorization handling
- Heart rate and HRV data queries
- Workout session creation
- Compatible with watchOS 7+ and iOS 14+

**DataManager**
- Singleton managing persistent storage
- UserDefaults-based storage for settings and events
- Event CRUD operations
- Session management
- Data export (JSON/CSV)

### 2. Configuration Layer

**AppConfiguration.swift**
- Centralized constants and thresholds
- Detection algorithm parameters
- Sampling rates
- Battery and performance targets
- Sensitivity presets (low/medium/high/custom)

## watchOS App Architecture

### Services (`watchOS/Services/`)

**HeartRateMonitor**
- Manages continuous HR monitoring using `HKWorkoutSession`
- Implements `HKWorkoutSessionDelegate` and `HKLiveWorkoutBuilderDelegate`
- Adaptive sampling rate based on HR stability
- Power saving mode support
- Maintains rolling buffer of recent samples for analysis

**DetectionEngine**
- Analyzes heart rate samples for arousal events
- Implements three detection algorithms:
  1. **Absolute Threshold**: HR exceeds configured BPM limit
  2. **Relative Delta**: HR rises by X bpm within Y seconds
  3. **HRV Drop**: HRV decreases by configured percentage
- Integrates CoreMotion for movement-based false positive suppression
- Cooldown period to prevent alert spam

**HapticManager**
- Manages haptic feedback using `WKInterfaceDevice`
- Local notification delivery
- Notification action handling (acknowledge/snooze/dismiss)
- Success/failure haptic patterns

**ExtensionDelegate**
- watchOS app lifecycle management
- Background task handling
- Notification center delegation
- WatchConnectivity background tasks

### Views (`watchOS/Views/`)

**MonitoringView**
- Real-time heart rate display
- Start/stop monitoring controls
- Session statistics (min/avg/max HR)
- Visual status indicators
- Color-coded HR display based on thresholds

**EventListView**
- List of recent detection events
- Event details (time, HR, type, confidence)
- Response status indicators

**SettingsView**
- Sensitivity preset picker
- Haptic/sound toggles
- Power saving mode
- Test alert button

## iOS App Architecture

### Services (`iOS/Services/`)

**WatchConnectivityManager**
- Bidirectional sync between iPhone and Apple Watch
- Implements `WCSessionDelegate`
- Settings synchronization
- Event data transfer
- Real-time messaging when watch is reachable
- Background data transfer via `transferUserInfo`

**NotificationManager**
- Fallback notifications when watch not worn
- Sleep window reminders
- Implements `UNUserNotificationCenterDelegate`
- Badge management

### Views (`iOS/Views/`)

**OnboardingView**
- Multi-page introduction flow
- Feature explanation
- Medical disclaimer
- Permission requests (HealthKit, Motion, Notifications)

**DashboardView**
- Watch connection status
- Sleep window configuration display
- Recent activity summary
- Quick action buttons

**EventLogView**
- Detailed event history grouped by date
- Export functionality (JSON/CSV)
- Event detail rows with full metadata
- Clear all events option

**SettingsView**
- Comprehensive settings interface
- Sleep window time pickers
- Sensitivity configuration with custom sliders
- Alert preferences
- Power management
- Data & privacy settings
- About section with disclaimers

## Data Flow

### Monitoring Flow (watchOS)

```
1. User starts monitoring
2. HeartRateMonitor creates HKWorkoutSession
3. HKLiveWorkoutBuilder delivers HR samples
4. HeartRateMonitor adds samples to buffer
5. DetectionEngine analyzes each sample
6. If detection criteria met:
   a. Create DetectionEvent
   b. Save to DataManager
   c. Trigger HapticManager alert
   d. Send notification
7. User responds to alert (acknowledge/snooze/dismiss)
8. Event updated with response
9. Continue monitoring until window ends
```

### Sync Flow (iOS ↔ watchOS)

```
Settings Changed on iPhone:
1. User modifies settings in iOS app
2. DataManager saves settings locally
3. WatchConnectivityManager sends settings to watch
4. Watch receives and applies settings

Event Detected on Watch:
1. DetectionEngine creates event
2. DataManager saves event locally on watch
3. WatchConnectivityManager transfers event to iPhone
4. iPhone receives and merges event
5. NotificationManager sends fallback notification (if enabled)
```

## Detection Algorithm Details

### Baseline Calculation
- Uses rolling average of last 30 samples
- Excludes outliers and movement-affected samples
- Recalculated continuously during monitoring

### Absolute Threshold Detection
```swift
if currentHR > absoluteHRThreshold {
    // Trigger detection
    confidence = (currentHR - threshold) / threshold
}
```

### Relative Delta Detection
```swift
samplesInWindow = samples from last N seconds
minHR = minimum HR in window
delta = currentHR - minHR

if delta > relativeDeltaThreshold {
    // Trigger detection
    confidence = delta / threshold
}
```

### HRV Drop Detection
```swift
recentHRV = average of last 10 HRV samples
currentHRV = latest HRV sample
dropPercentage = ((recentHRV - currentHRV) / recentHRV) * 100

if dropPercentage > hrvDropThreshold {
    // Trigger detection
    confidence = dropPercentage / threshold
}
```

### Movement Suppression
- Accelerometer magnitude calculated: `sqrt(x² + y² + z²)`
- If magnitude > threshold in last 30 seconds, detection suppressed
- Movement events logged but don't prevent detection entirely
- Flag `wasMovementSuppressed` added to events for analysis

## Power Management

### Adaptive Sampling
- **Active mode**: 1 sample/second during unstable HR
- **Stable mode**: 1 sample/30 seconds when HR stable
- **Power saving**: 1 sample/60 seconds (manual mode)

### Stability Detection
- HR considered stable after 10 consecutive readings within 5 bpm range
- Automatically switches sampling rate
- Reduces battery drain during stable periods

### Battery Targets
- Target: <10% additional drain overnight
- Monitoring via workout session is battery-intensive
- Power saving mode recommended for devices with <20% battery

## Error Handling

### HealthKit Unavailable
- Check `HKHealthStore.isHealthDataAvailable()`
- Display clear error message to user
- Prompt to grant permissions if not authorized

### Sensor Unavailability
- Monitor for nil/invalid HR readings
- Display "No heart rate data" warning
- Suggest user check watch fit and wrist detection

### Connectivity Loss
- WatchConnectivity handles automatic reconnection
- Events queued and synced when connection restored
- User notified of sync status on dashboard

### Background Interruptions
- Workout session maintains background execution
- Handle session state changes (running/paused/ended)
- Gracefully restart monitoring if interrupted

## Testing Strategy

### Unit Tests (Recommended)

**DetectionEngineTests**
- Test each detection algorithm with synthetic data
- Verify threshold calculations
- Test cooldown period enforcement
- Verify movement suppression logic

**HeartRateMonitorTests**
- Test sampling rate adjustments
- Verify baseline calculations
- Test buffer management

**DataManagerTests**
- Test CRUD operations for events
- Verify data retention policy
- Test export functionality

### Integration Tests (Recommended)

**MonitoringFlowTests**
- End-to-end monitoring session
- Verify events saved and synced
- Test alert delivery

**SyncTests**
- Settings sync between devices
- Event transfer
- Offline/online scenarios

### Acceptance Criteria

✅ **Functional Requirements**
- [x] watchOS 7+ and iOS 14+ support
- [x] HealthKit permissions implemented
- [x] Continuous HR monitoring during sleep window
- [x] Detection algorithm with configurable thresholds
- [x] Haptic + sound alerts
- [x] Local persistence and watch-phone sync
- [x] Privacy strings in Info.plist

⏳ **Performance Targets** (To be validated)
- [ ] Alert latency <5 seconds
- [ ] Battery usage <10% overnight
- [ ] Detection accuracy: >80% sensitivity
- [ ] False positive rate: <5%

## Future Enhancements

### ML Model Integration
- Hook for CoreML model already in DetectionEngine
- `AppConfiguration.enableMLDetection` flag
- Model versioning support included
- Would enable more sophisticated pattern recognition

### CloudKit Sync
- Flag in settings: `enableCloudSync`
- Would sync events across multiple devices
- Backup for data safety
- Opt-in for privacy

### Complication Support
- Quick glance at monitoring status
- Recent event count
- Next sleep window countdown

### Advanced Analytics
- Sleep quality scoring
- Trend analysis over time
- Event pattern recognition
- Correlation with external factors

## Backwards Compatibility

### Minimum OS Versions
- **watchOS**: 7.0 (supports Apple Watch Series 4+)
- **iOS**: 14.0

### API Compatibility
- Uses standard HealthKit APIs available since watchOS 7
- HKWorkoutSession for background HR access
- WatchConnectivity for device communication
- CoreMotion for accelerometer data

### Device Compatibility
- Apple Watch Series 4 and later (optical heart rate sensor required)
- iPhone 6s and later (iOS 14+ support)

## Security & Privacy

### Data Storage
- All health data stored locally on device
- No cloud upload unless explicitly enabled by user
- UserDefaults encrypted by iOS/watchOS

### Data Sharing
- HealthKit data never leaves device without permission
- Export feature gives user full control
- Telemetry is opt-in only

### Permissions
- Explicit permission requests with clear rationale
- Minimum required permissions requested
- User can revoke at any time via Settings

## Performance Optimization

### Memory Management
- Fixed-size buffers to prevent memory growth
- Events limited to configurable maximum (default: 1000)
- Old events automatically pruned based on retention policy

### CPU Usage
- Detection runs on background queue
- UI updates dispatched to main queue
- Sampling rate adapts to reduce processing

### Network Usage
- WatchConnectivity handles efficient sync
- Only changed data transmitted
- Background transfers for non-urgent data
