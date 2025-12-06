# iTrack - Setup Guide

## Xcode Project Setup

This guide explains how to create the Xcode project and import the skeleton code.

### Prerequisites

- macOS with Xcode 14.2 or later
- Apple Watch Series 4+ for testing
- iPhone running iOS 14+ for testing
- Apple Developer account (for device testing)

### Step 1: Create New Xcode Project

1. Open Xcode 14.2
2. Select **File > New > Project**
3. Choose **iOS > App** template
4. Configure project:
   - Product Name: `iTrack`
   - Team: Select your development team
   - Organization Identifier: `com.yourcompany`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** (we'll use UserDefaults and custom storage)
   - Include Tests: **Yes**

### Step 2: Add Watch App Target

1. Select your project in the navigator
2. Click **+** button at the bottom of the targets list
3. Select **watchOS > Watch App for iOS App**
4. Configure:
   - Product Name: `iTrack Watch`
   - Supports Complications: **No** (optional feature for later)

### Step 3: Enable Required Capabilities

#### For iOS App Target:
1. Select the iOS app target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** and add:
   - HealthKit
   - Background Modes (enable "Remote notifications")
   - Push Notifications (if using remote notifications)

#### For watchOS App Target:
1. Select the watchOS app extension target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** and add:
   - HealthKit
   - Background Modes (enable "Workout processing")

### Step 4: Import Source Files

Copy the source files from the repository to your Xcode project:

#### Shared Code:
Create groups in Xcode and add files:
- `Shared/Models/` → Add all model files
- `Shared/Services/` → Add HealthKitManager.swift, DataManager.swift
- `Shared/Configuration/` → Add AppConfiguration.swift

#### iOS App:
- `iOS/App/` → Replace App file and ContentView
- `iOS/Views/` → Add all view files
- `iOS/Services/` → Add WatchConnectivityManager.swift, NotificationManager.swift
- Replace `Info.plist` with the provided iOS Info.plist

#### watchOS App:
- `watchOS/App/` → Replace App file and ContentView
- `watchOS/Views/` → Add all view files
- `watchOS/Services/` → Add all service files
- Replace `Info.plist` with the provided watchOS Info.plist

### Step 5: Configure Info.plist Files

The provided Info.plist files already include required permissions. Verify they contain:

**iOS Info.plist:**
- NSHealthShareUsageDescription
- NSHealthUpdateUsageDescription
- NSMotionUsageDescription
- UIBackgroundModes
- NSPrivacyPolicyURL

**watchOS Info.plist:**
- NSHealthShareUsageDescription
- NSHealthUpdateUsageDescription
- NSMotionUsageDescription
- UIBackgroundModes (workout-processing)
- WKApplication = YES

### Step 6: Update Privacy Policy URL

Update the placeholder URLs in both Info.plist files:
- Replace `https://example.com/privacy` with your actual privacy policy URL
- Replace `https://example.com/terms` with your terms of service URL
- Replace `https://example.com/support` with your support page URL

### Step 7: Configure Signing

1. Select iOS app target → **Signing & Capabilities**
2. Select your development team
3. Xcode will automatically generate provisioning profiles
4. Repeat for watchOS app target

### Step 8: Add Frameworks

The following frameworks should be linked automatically, but verify in **Build Phases > Link Binary With Libraries**:

**iOS App:**
- HealthKit.framework
- WatchConnectivity.framework
- UserNotifications.framework
- SwiftUI.framework

**watchOS App:**
- HealthKit.framework
- WatchConnectivity.framework
- WatchKit.framework
- CoreMotion.framework
- UserNotifications.framework
- SwiftUI.framework

### Step 9: Build and Run

1. Select your iOS device or simulator as the target
2. Build the project (**⌘B**)
3. Fix any import or linking errors
4. Run on device (**⌘R**)

For watchOS app:
1. Select your Apple Watch or Watch simulator
2. Build and run

## Testing Setup

### Unit Tests

The skeleton includes hooks for unit tests. To add tests:

1. Create `iTrackTests` target if not exists
2. Add test files for:
   - Detection algorithm (`DetectionEngineTests.swift`)
   - Heart rate monitoring (`HeartRateMonitorTests.swift`)
   - Data management (`DataManagerTests.swift`)

### Test Detection Algorithm

Use the test event injection feature:
1. Run the app on watch
2. Navigate to Settings tab
3. Tap "Test Alert"
4. Verify haptic and notification appear

### Test with Real Data

1. Wear Apple Watch
2. Grant HealthKit permissions when prompted
3. Start monitoring from watch app
4. Check that heart rate updates appear
5. Manually trigger detection by increasing heart rate

## Configuration

### Adjust Thresholds

Edit `Shared/Configuration/AppConfiguration.swift` to customize:
- `absoluteHRThreshold` - Baseline BPM threshold
- `relativeHRDeltaThreshold` - BPM rise threshold
- `hrvDropThreshold` - HRV drop percentage
- Sampling rates
- Alert cooldown period

### Sensitivity Presets

Three presets are available (low/medium/high) in:
`AppConfiguration.SensitivityPreset`

Users can also configure custom thresholds from iOS app.

## Common Issues

### "HealthKit is not available"
- Ensure you're testing on a real device (HealthKit not available in simulator)
- Verify HealthKit capability is enabled in target settings
- Check Info.plist contains health usage descriptions

### "Watch not connected"
- Ensure iPhone and Watch are paired
- Verify WatchConnectivity is activated in AppDelegate
- Check both apps are installed on their respective devices

### "Background monitoring not working"
- Verify workout-processing background mode is enabled for watchOS
- Check that HKWorkoutSession is active
- Ensure battery is sufficient (power saving may limit background)

### Build errors
- Clean build folder (**⌘⇧K**)
- Delete DerivedData folder
- Verify all files are added to correct targets
- Check framework linking

## Next Steps

After setup:

1. **Test on device** - Deploy to physical iPhone and Apple Watch
2. **Verify permissions** - Complete onboarding flow and grant all permissions
3. **Calibrate thresholds** - Test with real sleep data and adjust sensitivity
4. **Implement ML model** (optional) - Add CoreML model for advanced detection
5. **Add CloudKit sync** (optional) - Implement cloud backup if needed
6. **Create privacy policy** - Required for App Store submission
7. **Add app icons** - Design and add app icons for iOS and watchOS
8. **Prepare for App Store** - Create screenshots, description, and metadata

## File Structure Reference

```
iTrack/
├── iOS/
│   ├── App/
│   │   ├── iTrackApp.swift              # iOS app entry point
│   │   ├── ContentView.swift            # Main navigation
│   │   └── Info.plist                   # iOS permissions & config
│   ├── Views/
│   │   ├── DashboardView.swift          # Main dashboard
│   │   ├── EventLogView.swift           # Event history
│   │   ├── SettingsView.swift           # Configuration
│   │   └── OnboardingView.swift         # First-time setup
│   └── Services/
│       ├── WatchConnectivityManager.swift
│       └── NotificationManager.swift
├── watchOS/
│   ├── App/
│   │   ├── iTrackWatchApp.swift         # watchOS app entry
│   │   ├── ContentView.swift            # Watch navigation
│   │   └── Info.plist                   # watchOS permissions
│   ├── Views/
│   │   ├── MonitoringView.swift         # HR monitoring UI
│   │   ├── EventListView.swift          # Event list
│   │   └── SettingsView.swift           # Watch settings
│   └── Services/
│       ├── HeartRateMonitor.swift       # HealthKit monitoring
│       ├── DetectionEngine.swift        # Detection algorithm
│       ├── HapticManager.swift          # Alerts & haptics
│       └── ExtensionDelegate.swift      # Extension lifecycle
└── Shared/
    ├── Models/
    │   ├── HeartRateData.swift          # HR/HRV data models
    │   ├── Event.swift                  # Detection event model
    │   └── Settings.swift               # User settings model
    ├── Services/
    │   ├── HealthKitManager.swift       # HealthKit interface
    │   └── DataManager.swift            # Persistence layer
    └── Configuration/
        └── AppConfiguration.swift        # Centralized config
```

## Resources

- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [WatchKit Programming Guide](https://developer.apple.com/documentation/watchkit)
- [WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
