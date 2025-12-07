//
//  DashboardView.swift
//  iTrack
//
//  Dashboard showing current status and recent activity
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Header
                    VStack(spacing: AppTheme.Spacing.sm) {
                        MoonGlowIcon(size: 48)
                        Text("FixSleep")
                            .font(AppTheme.Typography.largeTitle())
                            .foregroundColor(AppTheme.Text.primary)
                        Text("Monitor de Arousal Noturno")
                            .font(AppTheme.Typography.caption())
                            .foregroundColor(AppTheme.Text.muted)
                            .textCase(.uppercase)
                    }
                    .padding(.top, AppTheme.Spacing.lg)

                    // Watch connection status
                    watchStatusCard

                    // Sleep window card
                    sleepWindowCard

                    // Recent activity summary
                    recentActivityCard

                    // Quick actions
                    quickActionsCard
                }
                .padding()
            }
            .navigationBarHidden(true)
            .background(AppTheme.Background.deep)
        }
    }

    private var watchStatusCard: some View {
        ThemeInfoCard(
            icon: AppIcons.watch,
            title: "Apple Watch",
            subtitle: watchConnectivity.isWatchAppInstalled ? "Conectado" : "Desconectado",
            description: watchConnectivity.isWatchAppInstalled
                ? "O seu Apple Watch está sincronizado e pronto"
                : "Instale FixSleep no Apple Watch para começar",
            accentColor: watchConnectivity.isWatchAppInstalled
                ? AppTheme.Accent.mint
                : AppTheme.Accent.rose
        )
    }

    private var sleepWindowCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ThemeSectionHeader(
                "Janela de Sono",
                subtitle: "Período de Monitorização",
                icon: AppIcons.sleep
            )

            VStack(spacing: AppTheme.Spacing.md) {
                ThemeValueRow(
                    label: "Início",
                    value: sleepStartTime,
                    icon: "moon.fill",
                    accentColor: AppTheme.Accent.lavender
                )

                Divider()
                    .background(AppTheme.Border.subtle)

                ThemeValueRow(
                    label: "Fim",
                    value: sleepEndTime,
                    icon: "sunrise.fill",
                    accentColor: AppTheme.Accent.chamomile
                )

                if dataManager.settings.isWithinSleepWindow() {
                    Divider()
                        .background(AppTheme.Border.subtle)

                    HStack {
                        BreathingCircle(color: AppTheme.Accent.mint, size: 8)
                        Text("Dentro da janela de sono")
                            .font(AppTheme.Typography.caption())
                            .foregroundColor(AppTheme.Accent.mint)
                        Spacer()
                    }
                }
            }
        }
        .themeElevatedCard()
    }

    private var recentActivityCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                ThemeSectionHeader(
                    "Atividade Recente",
                    icon: AppIcons.chart
                )

                Spacer()

                NavigationLink(destination: EventLogView()) {
                    Text("Ver Tudo")
                        .font(AppTheme.Typography.caption(weight: .medium))
                        .foregroundColor(AppTheme.Accent.lavender)
                }
            }

            if dataManager.recentEvents.isEmpty {
                ThemeEmptyState(
                    icon: AppIcons.sleeping,
                    title: "Sem Eventos",
                    message: "Nenhum arousal detetado recentemente"
                )
            } else {
                VStack(spacing: AppTheme.Spacing.md) {
                    ThemeValueRow(
                        label: "Eventos Hoje",
                        value: "\(todayEventCount)",
                        icon: AppIcons.alert,
                        accentColor: AppTheme.Accent.chamomile
                    )

                    Divider()
                        .background(AppTheme.Border.subtle)

                    ThemeValueRow(
                        label: "Esta Semana",
                        value: "\(weekEventCount)",
                        icon: AppIcons.schedule,
                        accentColor: AppTheme.Accent.lavender
                    )

                    if let lastEvent = dataManager.recentEvents.last {
                        Divider()
                            .background(AppTheme.Border.subtle)

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Último Evento")
                                    .font(AppTheme.Typography.caption())
                                    .foregroundColor(AppTheme.Text.muted)

                                Text(lastEvent.detectionType.rawValue)
                                    .font(AppTheme.Typography.body(weight: .medium))
                                    .foregroundColor(AppTheme.Text.primary)
                            }

                            Spacer()

                            Text(formatRelativeTime(lastEvent.timestamp))
                                .font(AppTheme.Typography.caption())
                                .foregroundColor(AppTheme.Text.secondary)
                        }
                    }
                }
            }
        }
        .themeCard()
    }

    private var quickActionsCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ThemeSectionHeader("Ações Rápidas")

            VStack(spacing: AppTheme.Spacing.sm) {
                NavigationLink(destination: SettingsView()) {
                    HStack {
                        ThemedIcon(AppIcons.settings, size: 18, color: AppTheme.Accent.lavender)
                        Text("Ajustar Sensibilidade")
                            .font(AppTheme.Typography.body())
                            .foregroundColor(AppTheme.Text.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Text.muted)
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(AppTheme.CornerRadius.md)
                }

                NavigationLink(destination: EventLogView()) {
                    HStack {
                        ThemedIcon(AppIcons.export, size: 18, color: AppTheme.Accent.mint)
                        Text("Exportar Eventos")
                            .font(AppTheme.Typography.body())
                            .foregroundColor(AppTheme.Text.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Text.muted)
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(AppTheme.CornerRadius.md)
                }
            }
        }
        .themeCard()
    }

    // MARK: - Computed Properties

    private var sleepStartTime: String {
        formatTime(
            hour: dataManager.settings.sleepWindowStart.hour ?? 22,
            minute: dataManager.settings.sleepWindowStart.minute ?? 0
        )
    }

    private var sleepEndTime: String {
        formatTime(
            hour: dataManager.settings.sleepWindowEnd.hour ?? 7,
            minute: dataManager.settings.sleepWindowEnd.minute ?? 0
        )
    }

    private var todayEventCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return dataManager.recentEvents.filter {
            Calendar.current.isDate($0.timestamp, inSameDayAs: today)
        }.count
    }

    private var weekEventCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return dataManager.recentEvents.filter { $0.timestamp > weekAgo }.count
    }

    // MARK: - Helper Functions

    private func formatTime(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }

        return "--:--"
    }

    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .preferredColorScheme(.dark)
    }
}
