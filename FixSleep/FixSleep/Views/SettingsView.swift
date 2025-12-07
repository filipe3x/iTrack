//
//  SettingsView.swift
//  iTrack
//
//  Comprehensive settings interface for iOS
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared

    var body: some View {
        NavigationView {
            List {
                sleepWindowSection
                sensitivitySection
                alertsSection
                powerSection
                dataSection
                privacySection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Sections

    private var sleepWindowSection: some View {
        Section {
            DatePicker(
                "Start Time",
                selection: sleepStartBinding,
                displayedComponents: .hourAndMinute
            )

            DatePicker(
                "End Time",
                selection: sleepEndBinding,
                displayedComponents: .hourAndMinute
            )
        } header: {
            Text("Sleep Window")
        } footer: {
            Text("Monitoring will be active during this time window")
        }
    }

    private var sensitivitySection: some View {
        Section {
            Picker("Sensitivity Preset", selection: $sensitivityPreset) {
                ForEach(AppConfiguration.SensitivityPreset.allCases, id: \.self) { preset in
                    Text(preset.rawValue.capitalized)
                        .tag(preset)
                }
            }

            if dataManager.settings.sensitivityPreset == .custom {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Absolute Threshold: \(Int(customAbsoluteThreshold)) bpm")
                        .font(.subheadline)

                    Slider(value: $customAbsoluteThreshold, in: 60...120, step: 5)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Relative Delta: \(Int(customRelativeDelta)) bpm")
                        .font(.subheadline)

                    Slider(value: $customRelativeDelta, in: 5...30, step: 1)
                }
            }
        } header: {
            Text("Detection Sensitivity")
        } footer: {
            Text(sensitivityDescription)
        }
    }

    private var alertsSection: some View {
        Section {
            Toggle("Haptic Feedback", isOn: enableHaptics)
            Toggle("Audible Alarm", isOn: enableSound)
            Toggle("iPhone Notifications", isOn: notificationsEnabled)
        } header: {
            Text("Alerts & Notifications")
        } footer: {
            Text("Customize how you receive alerts for detected events")
        }
    }

    private var powerSection: some View {
        Section {
            Toggle("Power Saving Mode", isOn: powerSavingMode)

            VStack(alignment: .leading, spacing: 4) {
                Text("Battery Impact")
                    .font(.subheadline)

                Text("Target: <\(Int(AppConfiguration.targetBatteryDrainPercent))% overnight")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Power Management")
        } footer: {
            Text("Power saving reduces sampling frequency to conserve battery")
        }
    }

    private var dataSection: some View {
        Section {
            Toggle("Cloud Sync", isOn: cloudSync)
            Toggle("Anonymized Telemetry", isOn: telemetry)

            HStack {
                Text("Data Retention")
                Spacer()
                Text("\(AppConfiguration.dataRetentionDays) days")
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Stored Events")
                Spacer()
                Text("\(dataManager.loadAllEvents().count)")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Data & Storage")
        }
    }

    private var privacySection: some View {
        Section {
            if healthKitManager.isAuthorized {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("HealthKit Authorized")
                }
            } else {
                Button("Grant HealthKit Access") {
                    requestHealthKitAuth()
                }
            }

            Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
        } header: {
            Text("Privacy & Permissions")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("ML Model Version")
                Spacer()
                Text(AppConfiguration.mlModelVersion)
                    .foregroundColor(.secondary)
            }

            Link("Support & Feedback", destination: URL(string: "https://example.com/support")!)
        } header: {
            Text("About")
        } footer: {
            VStack(alignment: .leading, spacing: 8) {
                Text("iTrack is not a medical device")
                    .font(.caption)
                    .foregroundColor(.orange)

                Text("Not intended for diagnosis or treatment of any medical condition. Consult healthcare professionals for medical advice.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Computed Bindings

    private var sleepStartBinding: Binding<Date> {
        Binding(
            get: {
                var components = dataManager.settings.sleepWindowStart
                components.second = 0
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                dataManager.updateSettings { settings in
                    settings.sleepWindowStart = components
                }
            }
        )
    }

    private var sleepEndBinding: Binding<Date> {
        Binding(
            get: {
                var components = dataManager.settings.sleepWindowEnd
                components.second = 0
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                dataManager.updateSettings { settings in
                    settings.sleepWindowEnd = components
                }
            }
        )
    }

    @State private var sensitivityPreset = AppConfiguration.SensitivityPreset.medium
    @State private var customAbsoluteThreshold = AppConfiguration.absoluteHRThreshold
    @State private var customRelativeDelta = AppConfiguration.relativeHRDeltaThreshold

    private var enableHaptics: Binding<Bool> {
        Binding(
            get: { dataManager.settings.enableHaptics },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.enableHaptics = newValue
                }
            }
        )
    }

    private var enableSound: Binding<Bool> {
        Binding(
            get: { dataManager.settings.enableAudibleAlarm },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.enableAudibleAlarm = newValue
                }
            }
        )
    }

    private var notificationsEnabled: Binding<Bool> {
        Binding(
            get: { dataManager.settings.notificationsEnabled },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.notificationsEnabled = newValue
                }
            }
        )
    }

    private var powerSavingMode: Binding<Bool> {
        Binding(
            get: { dataManager.settings.enablePowerSavingMode },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.enablePowerSavingMode = newValue
                }
            }
        )
    }

    private var cloudSync: Binding<Bool> {
        Binding(
            get: { dataManager.settings.enableCloudSync },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.enableCloudSync = newValue
                }
            }
        )
    }

    private var telemetry: Binding<Bool> {
        Binding(
            get: { dataManager.settings.enableTelemetry },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.enableTelemetry = newValue
                }
            }
        )
    }

    // MARK: - Helpers

    private var sensitivityDescription: String {
        switch dataManager.settings.sensitivityPreset {
        case .low:
            return "Less sensitive - fewer alerts, may miss some events"
        case .medium:
            return "Balanced sensitivity - recommended for most users"
        case .high:
            return "More sensitive - more alerts, may include false positives"
        case .custom:
            return "Custom thresholds configured"
        }
    }

    private func requestHealthKitAuth() {
        Task {
            try? await healthKitManager.requestAuthorization()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
