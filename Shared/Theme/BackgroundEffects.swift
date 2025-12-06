//
//  BackgroundEffects.swift
//  FixSleep
//
//  Animated background effects matching website aesthetic
//  Starfield and gradient orbs for deep night sky theme
//

import SwiftUI

// MARK: - Starfield Background

/// Animated starfield background matching website's night sky
struct StarfieldBackground: View {
    let starCount: Int
    @State private var stars: [Star] = []

    init(starCount: Int = 50) {
        self.starCount = starCount
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep background
                AppTheme.Background.deep
                    .ignoresSafeArea()

                // Animated stars
                ForEach(stars) { star in
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x * geometry.size.width, y: star.y * geometry.size.height)
                        .opacity(star.currentOpacity)
                        .blur(radius: star.blur)
                }
            }
            .onAppear {
                generateStars(in: geometry.size)
                animateStars()
            }
        }
    }

    private func generateStars(in size: CGSize) {
        stars = (0..<starCount).map { _ in
            Star(
                x: .random(in: 0...1),
                y: .random(in: 0...1),
                size: .random(in: 1...2.5),
                blur: .random(in: 0...0.5),
                duration: .random(in: 2...6),
                delay: .random(in: 0...4),
                maxOpacity: .random(in: 0.3...1.0)
            )
        }
    }

    private func animateStars() {
        for index in stars.indices {
            animateStar(at: index)
        }
    }

    private func animateStar(at index: Int) {
        let star = stars[index]

        DispatchQueue.main.asyncAfter(deadline: .now() + star.delay) {
            withAnimation(
                Animation.easeInOut(duration: star.duration)
                    .repeatForever(autoreverses: true)
            ) {
                stars[index].currentOpacity = star.maxOpacity
            }
        }
    }

    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let blur: CGFloat
        let duration: Double
        let delay: Double
        let maxOpacity: Double
        var currentOpacity: Double = 0
    }
}

// MARK: - Animated Gradient Orbs

/// Floating gradient orbs matching website's ambient effects
struct FloatingOrbs: View {
    @State private var orb1Offset: CGSize = .zero
    @State private var orb2Offset: CGSize = .zero

    var body: some View {
        ZStack {
            // Lavender orb (top-right)
            Circle()
                .fill(AppTheme.Gradients.lavenderOrb)
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 150 + orb1Offset.width, y: -100 + orb1Offset.height)
                .opacity(0.3)

            // Chamomile orb (bottom-left)
            Circle()
                .fill(AppTheme.Gradients.chamomileOrb)
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: -100 + orb2Offset.width, y: 200 + orb2Offset.height)
                .opacity(0.25)
        }
        .ignoresSafeArea()
        .onAppear {
            animateOrbs()
        }
    }

    private func animateOrbs() {
        // Orb 1 animation (20s cycle)
        withAnimation(
            Animation.easeInOut(duration: 20)
                .repeatForever(autoreverses: false)
        ) {
            orb1Offset = CGSize(width: 30, height: -30)
        }

        // Orb 2 animation (25s cycle, reverse)
        withAnimation(
            Animation.easeInOut(duration: 25)
                .repeatForever(autoreverses: false)
        ) {
            orb2Offset = CGSize(width: -20, height: 20)
        }
    }
}

// MARK: - Complete Night Sky Background

/// Combined starfield and orbs for full night sky effect
struct NightSkyBackground: View {
    var includeStars: Bool = true
    var includeOrbs: Bool = true

    var body: some View {
        ZStack {
            // Base deep background
            AppTheme.Background.deep
                .ignoresSafeArea()

            // Floating orbs
            if includeOrbs {
                FloatingOrbs()
            }

            // Starfield
            if includeStars {
                StarfieldBackground(starCount: 50)
            }
        }
    }
}

// MARK: - Breathing Circle Animation

/// Breathing circle animation for meditation/calm states
/// Matches the website's breath indicator
struct BreathingCircle: View {
    @State private var isAnimating = false
    var color: Color = AppTheme.Accent.lavender
    var size: CGFloat = 12

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? 1.2 : 0.8)
            .opacity(isAnimating ? 0.8 : 0.4)
            .onAppear {
                withAnimation(AppTheme.Animation.breathing) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Moon Glow Icon

/// Moon icon with pulsing glow effect
/// Matches website's animated moon header
struct MoonGlowIcon: View {
    @State private var glowIntensity: CGFloat = 0.4
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: "moon.fill")
            .font(.system(size: size))
            .foregroundStyle(AppTheme.Gradients.moon)
            .shadow(color: AppTheme.Accent.moon.opacity(glowIntensity), radius: 20)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 4)
                        .repeatForever(autoreverses: true)
                ) {
                    glowIntensity = 0.7
                }
            }
    }
}

// MARK: - Minimal Background (for watchOS)

/// Simplified background for watchOS performance
struct MinimalNightBackground: View {
    var body: some View {
        ZStack {
            // Base deep background
            AppTheme.Background.deep
                .ignoresSafeArea()

            // Single subtle orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.Accent.lavender.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 40)
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
struct BackgroundEffects_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Full night sky
            NightSkyBackground()
                .previewDisplayName("Night Sky - Full")

            // Starfield only
            NightSkyBackground(includeOrbs: false)
                .previewDisplayName("Starfield Only")

            // Orbs only
            NightSkyBackground(includeStars: false)
                .previewDisplayName("Orbs Only")

            // Minimal (watchOS)
            MinimalNightBackground()
                .previewDisplayName("Minimal - watchOS")

            // Breathing circle demo
            VStack(spacing: 20) {
                BreathingCircle()
                Text("Respira com a lua")
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Text.muted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Background.deep)
            .previewDisplayName("Breathing Circle")

            // Moon glow icon
            VStack {
                MoonGlowIcon(size: 60)
                Text("FixSleep")
                    .font(AppTheme.Typography.largeTitle())
                    .foregroundColor(AppTheme.Text.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Background.deep)
            .previewDisplayName("Moon Glow Icon")
        }
    }
}
#endif
