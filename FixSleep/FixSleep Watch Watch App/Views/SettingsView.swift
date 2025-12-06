//
//  SettingsView.swift
//  iTrack WatchKit Extension
//
//  Settings interface for watchOS
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataManager = DataManager.shared

    var body: some View {
        List {
            Section("Sensitivity") {
                Picker("Preset", selection: $sensitivityPreset) {
                    ForEach(AppConfiguration.SensitivityPreset.allCases, id: \.self) { preset in
                        Text(preset.rawValue.capitalized)
                            .tag(preset)
                    }
                }
            }

            Section("Alerts") {
                Toggle("Haptics", isOn: $haptics)
                Toggle("Sound", isOn: $sound)
            }

            Section("Power") {
                Toggle("Power Saving", isOn: $powerSaving)
            }

            Section {
                Button("Test Alert") {
                    DetectionEngine.shared.injectTestEvent()
                }
                .foregroundColor(.orange)
            }
        }
        .navigationTitle("Settings")
    }

    // MARK: - Computed Properties with Bindings

    private var sensitivityPreset: Binding<AppConfiguration.SensitivityPreset> {
        Binding(
            get: { dataManager.settings.sensitivityPreset },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.sensitivityPreset = newValue
                }
            }
        )
    }

    private var haptics: Binding<Bool> {
        Binding(
            get: { dataManager.settings.enableHaptics },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.enableHaptics = newValue
                }
            }
        )
    }

    private var sound: Binding<Bool> {
        Binding(
            get: { dataManager.settings.enableAudibleAlarm },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.enableAudibleAlarm = newValue
                }
            }
        )
    }

    private var powerSaving: Binding<Bool> {
        Binding(
            get: { dataManager.settings.enablePowerSavingMode },
            set: { newValue in
                dataManager.updateSettings { settings in
                    settings.enablePowerSavingMode = newValue
                }
                HeartRateMonitor.shared.enablePowerSavingMode(newValue)
            }
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
