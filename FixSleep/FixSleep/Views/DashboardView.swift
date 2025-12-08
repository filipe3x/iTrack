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
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(alignment: .center, spacing: AppTheme.Spacing.md) {
                ThemedIcon(AppIcons.watch, size: 22, color: watchStatusAccent)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple Watch")
                        .font(AppTheme.Typography.body(weight: .medium))
                        .foregroundColor(AppTheme.Text.primary)

                    HStack(spacing: AppTheme.Spacing.xs) {
                        ThemeStatusBadge(watchStatusLabel, color: watchStatusAccent, icon: watchStatusIcon)

                        if watchConnectivity.isReachable {
                            ThemeStatusBadge("Ligação direta", color: AppTheme.Accent.mint, icon: "antenna.radiowaves.left.and.right")
                        }

                        if let responded = watchConnectivity.lastHandshakeSucceeded {
                            ThemeStatusBadge(
                                responded ? "Resposta recebida" : "Sem resposta",
                                color: responded ? AppTheme.Accent.mint : AppTheme.Accent.chamomile,
                                icon: responded ? "checkmark" : "exclamationmark.triangle.fill"
                            )
                        }
                    }
                }

                Spacer()

                Button(action: { watchConnectivity.probeConnection() }) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "arrow.clockwise")
                        Text("Verificar")
                    }
                    .font(AppTheme.Typography.caption(weight: .medium))
                    .foregroundColor(AppTheme.Text.primary)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(AppTheme.CornerRadius.md)
                }
            }

            Text(watchStatusDescription)
                .font(AppTheme.Typography.caption(weight: .light))
                .foregroundColor(AppTheme.Text.secondary)
                .lineSpacing(3)

            Divider()
                .background(AppTheme.Border.subtle)

            VStack(spacing: AppTheme.Spacing.sm) {
                ThemeValueRow(
                    label: "Emparelhamento",
                    value: watchConnectivity.isPaired ? "Apple Watch encontrado" : "Nenhum relógio emparelhado",
                    icon: watchConnectivity.isPaired ? "link" : "link.badge.plus",
                    accentColor: watchConnectivity.isPaired ? AppTheme.Accent.mint : AppTheme.Accent.rose
                )

                ThemeValueRow(
                    label: "App FixSleep",
                    value: watchConnectivity.isWatchAppInstalled ? "Instalada no relógio" : "Instale via App Store",
                    icon: watchConnectivity.isWatchAppInstalled ? "applewatch" : "square.and.arrow.down",
                    accentColor: watchConnectivity.isWatchAppInstalled ? AppTheme.Accent.mint : AppTheme.Accent.chamomile
                )

                ThemeValueRow(
                    label: "Estado da ligação",
                    value: watchConnectivity.isReachable ? "Ligado agora" : "Sem ligação direta",
                    icon: watchConnectivity.isReachable ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash",
                    accentColor: watchConnectivity.isReachable ? AppTheme.Accent.mint : AppTheme.Accent.rose
                )

                ThemeValueRow(
                    label: "Última verificação",
                    value: lastWatchCheckLabel,
                    icon: "clock",
                    accentColor: AppTheme.Accent.lavender
                )

                if let error = watchConnectivity.lastHandshakeError {
                    ThemeValueRow(
                        label: "Aviso",
                        value: error,
                        icon: "exclamationmark.triangle.fill",
                        accentColor: AppTheme.Accent.rose
                    )
                }
            }
        }
        .themeElevatedCard(padding: AppTheme.Spacing.lg)
        .onAppear {
            watchConnectivity.probeConnection()
        }
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

    private var watchStatusAccent: Color {
        switch watchStatusState {
        case .unsupported, .notPaired: return AppTheme.Accent.rose
        case .missingApp: return AppTheme.Accent.chamomile
        case .reachable: return AppTheme.Accent.mint
        case .unreachable, .awaitingResponse: return AppTheme.Accent.lavender
        }
    }

    private var watchStatusLabel: String {
        switch watchStatusState {
        case .unsupported: return "Sem suporte"
        case .notPaired: return "Sem relógio"
        case .missingApp: return "App em falta"
        case .unreachable: return "Indisponível"
        case .awaitingResponse: return "A verificar"
        case .reachable: return "Conectado"
        }
    }

    private var watchStatusIcon: String {
        switch watchStatusState {
        case .unsupported: return "bolt.slash"
        case .notPaired: return "link.badge.plus"
        case .missingApp: return "square.and.arrow.down"
        case .unreachable: return "wifi.slash"
        case .awaitingResponse: return "arrow.triangle.2.circlepath"
        case .reachable: return "checkmark.seal.fill"
        }
    }

    private var watchStatusDescription: String {
        switch watchStatusState {
        case .unsupported:
            return "Este dispositivo não suporta comunicação com Apple Watch."
        case .notPaired:
            return "Não encontrámos um Apple Watch emparelhado. Emparelhe-o na app Watch do iPhone."
        case .missingApp:
            return "Detectámos o relógio, mas a app FixSleep não está instalada. Instale no Apple Watch para sincronizar."
        case .unreachable:
            return "O relógio está emparelhado, mas não conseguimos contacto agora. Abra o FixSleep no Apple Watch e mantenha-o próximo."
        case .awaitingResponse:
            return "Estamos a contactar o seu Apple Watch para confirmar a ligação e o estado da app."
        case .reachable:
            if let lastCheck = watchConnectivity.lastStatusCheck {
                return "Ligação ativa ao relógio. Última resposta: \(formatRelativeTime(lastCheck))."
            }
            return "Ligação ativa ao relógio."
        }
    }

    private var lastWatchCheckLabel: String {
        if let last = watchConnectivity.lastStatusCheck {
            return formatRelativeTime(last)
        }
        return "Ainda sem verificações"
    }

    private enum WatchStatusState {
        case unsupported
        case notPaired
        case missingApp
        case unreachable
        case awaitingResponse
        case reachable
    }

    private var watchStatusState: WatchStatusState {
        if !watchConnectivity.isSupported {
            return .unsupported
        }

        if !watchConnectivity.isPaired {
            return .notPaired
        }

        if !watchConnectivity.isWatchAppInstalled {
            return .missingApp
        }

        if watchConnectivity.isReachable {
            if watchConnectivity.lastHandshakeSucceeded == true {
                return .reachable
            } else {
                return .awaitingResponse
            }
        }

        return .unreachable
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .preferredColorScheme(.dark)
    }
}
