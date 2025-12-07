//
//  CustomSensitivityView.swift
//  FixSleep WatchKit Extension
//
//  Custom sensitivity configuration screen
//

import SwiftUI

struct CustomSensitivityView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var absoluteThreshold: Double
    @State private var relativeDelta: Double

    init() {
        let settings = DataManager.shared.settings
        _absoluteThreshold = State(initialValue: settings.customAbsoluteThreshold ?? 80.0)
        _relativeDelta = State(initialValue: settings.customRelativeDelta ?? 15.0)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.Gradients.moon)

                    Text("Sensibilidade Personalizada")
                        .font(AppTheme.Typography.caption(weight: .medium))
                        .foregroundColor(AppTheme.Text.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                // Absolute Threshold
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Accent.rose)

                        Text("FC Absoluta")
                            .font(AppTheme.Typography.caption(weight: .medium))
                            .foregroundColor(AppTheme.Text.primary)

                        Spacer()

                        Text("\(Int(absoluteThreshold)) bpm")
                            .font(AppTheme.Typography.caption(weight: .semibold))
                            .foregroundColor(AppTheme.Accent.rose)
                    }

                    Text("Alerta quando FC exceder este valor")
                        .font(AppTheme.Typography.tiny())
                        .foregroundColor(AppTheme.Text.muted)

                    Slider(value: $absoluteThreshold, in: 60...100, step: 5)
                        .accentColor(AppTheme.Accent.rose)
                }
                .padding(12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(AppTheme.CornerRadius.md)

                // Relative Delta
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Accent.chamomile)

                        Text("Delta Relativa")
                            .font(AppTheme.Typography.caption(weight: .medium))
                            .foregroundColor(AppTheme.Text.primary)

                        Spacer()

                        Text("+\(Int(relativeDelta)) bpm")
                            .font(AppTheme.Typography.caption(weight: .semibold))
                            .foregroundColor(AppTheme.Accent.chamomile)
                    }

                    Text("Aumento rápido de FC em 60s")
                        .font(AppTheme.Typography.tiny())
                        .foregroundColor(AppTheme.Text.muted)

                    Slider(value: $relativeDelta, in: 5...30, step: 5)
                        .accentColor(AppTheme.Accent.chamomile)
                }
                .padding(12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(AppTheme.CornerRadius.md)

                // Preset comparison
                VStack(alignment: .leading, spacing: 6) {
                    Text("Comparação com Presets")
                        .font(AppTheme.Typography.tiny(weight: .medium))
                        .foregroundColor(AppTheme.Text.muted)
                        .textCase(.uppercase)

                    presetComparisonRow("Low", abs: 90, rel: 20)
                    presetComparisonRow("Medium", abs: 80, rel: 15)
                    presetComparisonRow("High", abs: 70, rel: 10)
                }
                .padding(12)
                .background(Color.white.opacity(0.02))
                .cornerRadius(AppTheme.CornerRadius.md)

                // Save button
                Button(action: saveSettings) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Guardar")
                            .font(AppTheme.Typography.caption(weight: .semibold))
                    }
                    .foregroundColor(AppTheme.Background.deep)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(AppTheme.Accent.mint)
                    .cornerRadius(AppTheme.CornerRadius.full)
                    .shadow(
                        color: AppTheme.Accent.mint.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .navigationTitle("Custom")
    }

    private func presetComparisonRow(_ name: String, abs: Int, rel: Int) -> some View {
        HStack {
            Text(name)
                .font(AppTheme.Typography.tiny())
                .foregroundColor(AppTheme.Text.secondary)

            Spacer()

            Text("\(abs) / +\(rel)")
                .font(AppTheme.Typography.tiny(weight: .medium))
                .foregroundColor(AppTheme.Text.muted)
        }
    }

    private func saveSettings() {
        dataManager.updateSettings { settings in
            settings.customAbsoluteThreshold = absoluteThreshold
            settings.customRelativeDelta = relativeDelta
            settings.sensitivityPreset = .custom
        }
        dismiss()
    }
}

struct CustomSensitivityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomSensitivityView()
        }
    }
}
