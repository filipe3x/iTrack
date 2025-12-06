//
//  ThemeComponents.swift
//  FixSleep
//
//  Reusable UI components matching website branding
//

import SwiftUI

// MARK: - Section Header

/// Section header with elegant serif title
struct ThemeSectionHeader: View {
    let title: String
    let subtitle: String?
    let icon: String?

    init(_ title: String, subtitle: String? = nil, icon: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.md) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.Gradients.moon)
                }

                Text(title)
                    .font(AppTheme.Typography.title())
                    .foregroundColor(AppTheme.Text.primary)
                    .tracking(0.5)
            }

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Text.muted)
                    .textCase(.uppercase)
                    .tracking(1.5)
            }
        }
    }
}

// MARK: - Info Card

/// Card with icon, title, and description
/// Matches the website's compound cards
struct ThemeInfoCard: View {
    let icon: String
    let title: String
    let subtitle: String?
    let description: String
    let accentColor: Color

    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        description: String,
        accentColor: Color = AppTheme.Accent.lavender
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.accentColor = accentColor
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(accentColor)
                .frame(width: 24)

            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                // Title & Subtitle
                HStack(alignment: .center) {
                    Text(title)
                        .font(AppTheme.Typography.body(weight: .medium))
                        .foregroundColor(AppTheme.Text.primary)

                    if let subtitle = subtitle {
                        Spacer()
                        Text(subtitle)
                            .font(AppTheme.Typography.tiny(weight: .regular))
                            .foregroundColor(accentColor)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, 3)
                            .background(accentColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                }

                // Description
                Text(description)
                    .font(AppTheme.Typography.caption(weight: .light))
                    .foregroundColor(AppTheme.Text.secondary)
                    .lineSpacing(3)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(Color.white.opacity(0.02))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.md)
    }
}

// MARK: - Status Badge

/// Colored badge for status indicators
struct ThemeStatusBadge: View {
    let text: String
    let color: Color
    let icon: String?

    init(_ text: String, color: Color = AppTheme.Accent.lavender, icon: String? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }
            Text(text)
                .font(AppTheme.Typography.tiny(weight: .medium))
                .textCase(.uppercase)
                .tracking(0.8)
        }
        .foregroundColor(color)
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(AppTheme.CornerRadius.sm)
    }
}

// MARK: - Timeline Step (for settings/events)

/// Timeline step indicator matching website's protocol timeline
struct TimelineStep: View {
    let time: String
    let label: String
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    let isLast: Bool

    init(
        time: String,
        label: String,
        icon: String,
        title: String,
        description: String,
        accentColor: Color = AppTheme.Accent.lavender,
        isLast: Bool = false
    ) {
        self.time = time
        self.label = label
        self.icon = icon
        self.title = title
        self.description = description
        self.accentColor = accentColor
        self.isLast = isLast
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.lg) {
            // Time block
            VStack(alignment: .trailing, spacing: 2) {
                Text(time)
                    .font(AppTheme.Typography.body(weight: .medium))
                    .foregroundColor(AppTheme.Accent.moon)

                Text(label)
                    .font(AppTheme.Typography.tiny())
                    .foregroundColor(AppTheme.Text.muted)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            .frame(width: 60, alignment: .trailing)

            // Timeline indicator
            VStack(spacing: 0) {
                // Dot
                Circle()
                    .fill(AppTheme.Background.deep)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(accentColor, lineWidth: 2)
                            .shadow(color: accentColor.opacity(0.4), radius: 5)
                    )

                // Line (if not last)
                if !isLast {
                    Rectangle()
                        .fill(accentColor.opacity(0.3))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 8)

            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                ThemeInfoCard(
                    icon: icon,
                    title: title,
                    description: description,
                    accentColor: accentColor
                )
            }
            .padding(.bottom, isLast ? 0 : AppTheme.Spacing.lg)
        }
    }
}

// MARK: - Value Display Row

/// Row displaying a label and value
struct ThemeValueRow: View {
    let label: String
    let value: String
    let icon: String?
    let accentColor: Color

    init(
        label: String,
        value: String,
        icon: String? = nil,
        accentColor: Color = AppTheme.Accent.lavender
    ) {
        self.label = label
        self.value = value
        self.icon = icon
        self.accentColor = accentColor
    }

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(accentColor)
            }

            Text(label)
                .font(AppTheme.Typography.body(weight: .light))
                .foregroundColor(AppTheme.Text.secondary)

            Spacer()

            Text(value)
                .font(AppTheme.Typography.body(weight: .medium))
                .foregroundColor(AppTheme.Text.primary)
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}

// MARK: - Action Button

/// Primary action button with theme styling
struct ThemeButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case danger

        var backgroundColor: Color {
            switch self {
            case .primary: return AppTheme.Accent.lavender
            case .secondary: return Color.white.opacity(0.1)
            case .danger: return AppTheme.Accent.rose
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary: return AppTheme.Background.deep
            case .secondary: return AppTheme.Text.primary
            case .danger: return AppTheme.Background.deep
            }
        }
    }

    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(AppTheme.Typography.body(weight: .medium))
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(style.backgroundColor)
            .cornerRadius(AppTheme.CornerRadius.md)
        }
    }
}

// MARK: - Empty State

/// Empty state view with icon and message
struct ThemeEmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppTheme.Gradients.moon)

            VStack(spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Typography.title(weight: .light))
                    .foregroundColor(AppTheme.Text.primary)

                Text(message)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Text.muted)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppTheme.Spacing.xxl)
    }
}

// MARK: - Loading Indicator

/// Themed loading indicator with breathing animation
struct ThemeLoadingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .stroke(AppTheme.Accent.lavender.opacity(0.2), lineWidth: 3)
                    .frame(width: 40, height: 40)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(AppTheme.Accent.lavender, lineWidth: 3)
                    .frame(width: 40, height: 40)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }

            Text("Carregando...")
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Text.muted)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ThemeComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                // Section Header
                ThemeSectionHeader(
                    "Rotina Noturna",
                    subtitle: "Protocolo de Sono",
                    icon: "moon.stars.fill"
                )

                // Info Card
                ThemeInfoCard(
                    icon: "heart.fill",
                    title: "Frequência Cardíaca",
                    subtitle: "85 bpm",
                    description: "Monitorização contínua durante o sono"
                )

                // Status Badges
                HStack {
                    ThemeStatusBadge("Ativo", color: AppTheme.Accent.mint, icon: "checkmark")
                    ThemeStatusBadge("Alerta", color: AppTheme.Accent.rose, icon: "exclamationmark")
                    ThemeStatusBadge("Pausado", color: AppTheme.Text.muted)
                }

                // Value Row
                VStack(spacing: 0) {
                    ThemeValueRow(label: "Início", value: "23:00", icon: "moon.fill")
                    Divider().background(AppTheme.Border.subtle)
                    ThemeValueRow(label: "Fim", value: "07:00", icon: "sunrise.fill")
                }
                .themeCard()

                // Buttons
                VStack(spacing: AppTheme.Spacing.sm) {
                    ThemeButton("Iniciar Monitorização", icon: "play.fill", style: .primary) {}
                    ThemeButton("Configurações", icon: "gear", style: .secondary) {}
                    ThemeButton("Parar", icon: "stop.fill", style: .danger) {}
                }

                // Empty State
                ThemeEmptyState(
                    icon: "moon.zzz.fill",
                    title: "Sem Eventos",
                    message: "Nenhum evento de arousal detetado esta noite"
                )
                .themeCard()

                // Loading
                ThemeLoadingIndicator()
            }
            .padding()
        }
        .background(AppTheme.Background.deep)
    }
}
#endif
