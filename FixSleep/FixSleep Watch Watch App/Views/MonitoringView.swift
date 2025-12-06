//
//  MonitoringView.swift
//  FixSleep WatchKit Extension
//
//  Main monitoring interface
//

import SwiftUI

struct MonitoringView: View {
    @StateObject private var heartRateMonitor = HeartRateMonitor.shared
    @StateObject private var dataManager = DataManager.shared
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Minimal background for watchOS
            MinimalNightBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    // Moon icon header
                    if #available(watchOS 8.0, *) {
                        Image(systemName: AppIcons.sleep)
                            .font(.system(size: 32))
                            .foregroundStyle(AppTheme.Gradients.moon)
                    } else {
                        Image(systemName: AppIcons.sleep)
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.Accent.mint)
                    }
                        .padding(.top, 8)

                    // Current heart rate display
                    VStack(spacing: 6) {
                        if #available(watchOS 9.0, *) {
                            Text("Frequência Cardíaca")
                                .font(AppTheme.Typography.caption())
                                .foregroundColor(AppTheme.Text.muted)
                                .textCase(.uppercase)
                        } else {
                            Text("Frequência Cardíaca")
                                .font(AppTheme.Typography.caption())
                                .foregroundColor(AppTheme.Text.muted)
                                .textCase(.uppercase)
                        }

                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text("\(Int(heartRateMonitor.currentHeartRate))")
                                .font(.system(size: 48, weight: .light, design: .rounded))
                                .foregroundColor(heartRateColor)

                            Text("BPM")
                                .font(AppTheme.Typography.caption())
                                .foregroundColor(AppTheme.Text.muted)
                        }
                    }

                    // HRV display (if available)
                    if let hrv = heartRateMonitor.currentHRV {
                        HStack(spacing: 4) {
                            Text("VFC:")
                                .font(AppTheme.Typography.tiny())
                                .foregroundColor(AppTheme.Text.muted)

                            Text("\(Int(hrv)) ms")
                                .font(AppTheme.Typography.caption(weight: .medium))
                                .foregroundColor(AppTheme.Accent.mint)
                        }
                    }

                    // Status indicator
                    statusIndicator

                    // Main action button
                    Button(action: toggleMonitoring) {
                        HStack(spacing: 6) {
                            Image(systemName: heartRateMonitor.isMonitoring ? AppIcons.stop : AppIcons.play)
                                .font(.system(size: 12))
                            Text(heartRateMonitor.isMonitoring ? "Parar" : "Iniciar")
                                .font(AppTheme.Typography.caption(weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .accentColor(heartRateMonitor.isMonitoring ? AppTheme.Accent.rose : AppTheme.Accent.mint)

                    // Session info
                    if heartRateMonitor.isMonitoring {
                        sessionInfo
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Erro"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var statusIndicator: some View {
        HStack(spacing: 6) {
            if heartRateMonitor.isMonitoring {
                BreathingCircle(color: AppTheme.Accent.mint, size: 6)
            } else {
                Circle()
                    .fill(AppTheme.Text.muted)
                    .frame(width: 6, height: 6)
            }

            Text(heartRateMonitor.isMonitoring ? "A Monitorizar" : "Inativo")
                .font(AppTheme.Typography.tiny())
                .foregroundColor(heartRateMonitor.isMonitoring ? AppTheme.Accent.mint : AppTheme.Text.muted)
        }
    }

    private var sessionInfo: some View {
        VStack(spacing: 8) {
            if let stats = heartRateMonitor.getStatistics() {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mín")
                            .font(AppTheme.Typography.tiny())
                            .foregroundColor(AppTheme.Text.muted)
                        Text("\(Int(stats.min))")
                            .font(AppTheme.Typography.caption(weight: .medium))
                            .foregroundColor(AppTheme.Accent.lavender)
                    }

                    Spacer()

                    VStack(alignment: .center, spacing: 2) {
                        Text("Méd")
                            .font(AppTheme.Typography.tiny())
                            .foregroundColor(AppTheme.Text.muted)
                        Text("\(Int(stats.avg))")
                            .font(AppTheme.Typography.caption(weight: .medium))
                            .foregroundColor(AppTheme.Text.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Máx")
                            .font(AppTheme.Typography.tiny())
                            .foregroundColor(AppTheme.Text.muted)
                        Text("\(Int(stats.max))")
                            .font(AppTheme.Typography.caption(weight: .medium))
                            .foregroundColor(AppTheme.Accent.rose)
                    }
                }
                .padding(8)
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }

            if let session = dataManager.currentSession {
                HStack {
                    Image(systemName: AppIcons.alert)
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Accent.chamomile)
                    Text("Eventos: \(session.detectedEvents.count)")
                        .font(AppTheme.Typography.tiny())
                        .foregroundColor(AppTheme.Text.secondary)
                }
            }
        }
        .padding(.top, 8)
    }

    private var heartRateColor: Color {
        let hr = heartRateMonitor.currentHeartRate
        if hr > dataManager.settings.effectiveAbsoluteThreshold {
            return AppTheme.Accent.rose
        } else if hr > dataManager.settings.effectiveAbsoluteThreshold * 0.8 {
            return AppTheme.Accent.chamomile
        } else {
            return AppTheme.Accent.mint
        }
    }

    private func toggleMonitoring() {
        if heartRateMonitor.isMonitoring {
            Task {
                await heartRateMonitor.stopMonitoring()
            }
        } else {
            Task {
                do {
                    try await heartRateMonitor.startMonitoring()
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct MonitoringView_Previews: PreviewProvider {
    static var previews: some View {
        MonitoringView()
    }
}
