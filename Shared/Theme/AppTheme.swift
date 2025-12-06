//
//  AppTheme.swift
//  iTrack
//
//  Branding based on Rotina Noturna website
//  Deep night sky theme with lavender, chamomile, and moon accents
//

import SwiftUI

/// Main theme configuration for iTrack app
/// Based on the Rotina Noturna sleep protocol website branding
struct AppTheme {

    // MARK: - Colors

    /// Background colors - deep night sky palette
    struct Background {
        /// Primary deep background (#0a0e1a)
        static let deep = Color(hex: "0a0e1a")

        /// Card/panel background (#111827)
        static let card = Color(hex: "111827")

        /// Elevated card background (slightly lighter)
        static let cardElevated = Color(hex: "1a1f2e")
    }

    /// Accent colors - inspired by sleep-enhancing compounds
    struct Accent {
        /// Lavender/purple (#a78bfa) - primary brand color
        static let lavender = Color(hex: "a78bfa")

        /// Chamomile/amber (#fbbf24) - warm highlights
        static let chamomile = Color(hex: "fbbf24")

        /// Moon/light lavender (#e0e7ff) - soft highlights
        static let moon = Color(hex: "e0e7ff")

        /// Mint (#6ee7b7) - success/positive states
        static let mint = Color(hex: "6ee7b7")

        /// Rose (#fda4af) - alerts/SOS states
        static let rose = Color(hex: "fda4af")
    }

    /// Text colors - legible on dark backgrounds
    struct Text {
        /// Primary text (#f1f5f9) - highest contrast
        static let primary = Color(hex: "f1f5f9")

        /// Secondary text (#94a3b8) - medium contrast
        static let secondary = Color(hex: "94a3b8")

        /// Muted text (#64748b) - low contrast for subtle info
        static let muted = Color(hex: "64748b")
    }

    /// Border and divider colors
    struct Border {
        /// Subtle border with lavender tint
        static let subtle = Color.white.opacity(0.08)

        /// Lavender border accent
        static let lavender = Accent.lavender.opacity(0.15)

        /// Card border
        static let card = Color.white.opacity(0.05)
    }

    // MARK: - Gradients

    /// Gradient definitions
    struct Gradients {
        /// Moon gradient (light lavender to purple)
        static let moon = LinearGradient(
            colors: [Accent.moon, Accent.lavender],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Card background gradient
        static let card = LinearGradient(
            colors: [
                Background.card.opacity(0.95),
                Background.deep.opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Lavender orb (for background effects)
        static let lavenderOrb = RadialGradient(
            colors: [Accent.lavender.opacity(0.3), Color.clear],
            center: .center,
            startRadius: 0,
            endRadius: 200
        )

        /// Chamomile orb (for background effects)
        static let chamomileOrb = RadialGradient(
            colors: [Accent.chamomile.opacity(0.2), Color.clear],
            center: .center,
            startRadius: 0,
            endRadius: 150
        )
    }

    // MARK: - Typography

    /// Font definitions
    struct Typography {
        /// Serif font for elegant titles (Cormorant Garamond style)
        /// Falls back to Georgia/Didot for classic serif look
        static let titleFont = "Georgia"

        /// Sans-serif for body text (Outfit style)
        /// Falls back to system rounded
        static let bodyFont = Font.system(.body, design: .rounded)

        /// Large title (for main headers)
        static func largeTitle(weight: Font.Weight = .light) -> Font {
            Font.custom(titleFont, size: 32).weight(weight)
        }

        /// Title (for section headers)
        static func title(weight: Font.Weight = .light) -> Font {
            Font.custom(titleFont, size: 24).weight(weight)
        }

        /// Subtitle (for secondary headers)
        static func subtitle(weight: Font.Weight = .regular) -> Font {
            Font.system(size: 14, weight: weight, design: .rounded)
        }

        /// Body text
        static func body(weight: Font.Weight = .regular) -> Font {
            Font.system(size: 16, weight: weight, design: .rounded)
        }

        /// Caption (small text)
        static func caption(weight: Font.Weight = .light) -> Font {
            Font.system(size: 12, weight: weight, design: .rounded)
        }

        /// Tiny text (for labels)
        static func tiny(weight: Font.Weight = .light) -> Font {
            Font.system(size: 10, weight: weight, design: .rounded)
        }
    }

    // MARK: - Spacing

    /// Consistent spacing values
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Corner Radius

    /// Corner radius values
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999
    }

    // MARK: - Shadows

    /// Shadow definitions
    struct Shadows {
        /// Subtle card shadow
        static let card = Color.black.opacity(0.3)

        /// Strong shadow for elevated elements
        static let elevated = Color.black.opacity(0.5)

        /// Glow effect (lavender)
        static let lavenderGlow = Accent.lavender.opacity(0.4)
    }

    // MARK: - Animation

    /// Standard animation durations
    struct Animation {
        static let fast = SwiftUI.Animation.easeOut(duration: 0.2)
        static let medium = SwiftUI.Animation.easeOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeOut(duration: 0.5)
        static let breathing = SwiftUI.Animation.easeInOut(duration: 4).repeatForever(autoreverses: true)
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

/// Card style modifier with theme branding
struct ThemeCardModifier: ViewModifier {
    var padding: CGFloat = AppTheme.Spacing.lg
    var showBorder: Bool = true

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.Background.card)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(showBorder ? AppTheme.Border.card : Color.clear, lineWidth: 1)
            )
            .cornerRadius(AppTheme.CornerRadius.lg)
            .shadow(color: AppTheme.Shadows.card, radius: 25, x: 0, y: 10)
    }
}

/// Elevated card with lavender glow
struct ThemeElevatedCardModifier: ViewModifier {
    var padding: CGFloat = AppTheme.Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(AppTheme.Gradients.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(AppTheme.Border.lavender, lineWidth: 1)
            )
            .shadow(color: AppTheme.Shadows.elevated, radius: 25, x: 0, y: 15)
            .shadow(color: AppTheme.Shadows.lavenderGlow, radius: 10, x: 0, y: 0)
    }
}

extension View {
    /// Apply theme card styling
    func themeCard(padding: CGFloat = AppTheme.Spacing.lg, showBorder: Bool = true) -> some View {
        self.modifier(ThemeCardModifier(padding: padding, showBorder: showBorder))
    }

    /// Apply elevated theme card styling with glow
    func themeElevatedCard(padding: CGFloat = AppTheme.Spacing.lg) -> some View {
        self.modifier(ThemeElevatedCardModifier(padding: padding))
    }
}
