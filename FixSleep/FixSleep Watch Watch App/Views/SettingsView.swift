//
//  SettingsView.swift
//  iTrack WatchKit Extension
//
//  Settings interface for watchOS
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingCustomSensitivity = false

    var body: some View {
        List {
            Section(header: Text("Sensitivity")) {
                ForEach(AppConfiguration.SensitivityPreset.allCases, id: \.self) { preset in
                    if preset == .custom {
                        NavigationLink(destination: CustomSensitivityView()) {
                            HStack {
                                Text(preset.rawValue.capitalized)
                                    .font(AppTheme.Typography.body())
                                Spacer()
                                if dataManager.settings.sensitivityPreset == preset {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.Accent.mint)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                        }
                    } else {
                        Button(action: {
                            dataManager.updateSettings { settings in
                                settings.sensitivityPreset = preset
                            }
                        }) {
                            HStack {
                                Text(preset.rawValue.capitalized)
                                    .font(AppTheme.Typography.body())
                                    .foregroundColor(AppTheme.Text.primary)
                                Spacer()
                                if dataManager.settings.sensitivityPreset == preset {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.Accent.mint)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                        }
                    }
                }
            }

            Section(header: Text("Alerts")) {
                Toggle("Haptics", isOn: haptics)
                Toggle("Sound", isOn: sound)
            }

            Section(header: Text("Power")) {
                Toggle("Power Saving", isOn: powerSaving)
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
