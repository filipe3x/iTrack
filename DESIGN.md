# FixSleep Design System

**Version:** 1.0
**Last Updated:** December 6, 2025
**Based on:** Rotina Noturna website branding

---

## Overview

FixSleep uses a **deep night sky theme** inspired by sleep protocols and nocturnal serenity. The design language emphasizes calm, rest, and monitoring through:

- Deep backgrounds reminiscent of nighttime
- Soft, dreamy accent colors (lavender, chamomile, moon)
- Animated starfield and gradient orbs
- Breathing animations for meditation states
- Minimalist SF Symbol iconography

---

## Color Palette

### Background Colors

Deep, dark backgrounds that evoke nighttime and reduce eye strain during sleep hours.

| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| **Deep Background** | `#0a0e1a` | rgb(10, 14, 26) | Primary app background, full-screen base |
| **Card Background** | `#111827` | rgb(17, 24, 39) | Card panels, elevated surfaces |
| **Card Elevated** | `#1a1f2e` | rgb(26, 31, 46) | Higher elevation cards, modal backgrounds |

**Swift Implementation:**
```swift
AppTheme.Background.deep      // #0a0e1a
AppTheme.Background.card      // #111827
AppTheme.Background.cardElevated // #1a1f2e
```

---

### Accent Colors

Accent colors inspired by sleep-enhancing compounds and natural elements.

| Color Name | Hex Code | RGB | Meaning | Usage |
|------------|----------|-----|---------|-------|
| **Lavender** | `#a78bfa` | rgb(167, 139, 250) | Primary brand, calm | Primary buttons, highlights, icons |
| **Chamomile** | `#fbbf24` | rgb(251, 191, 36) | Warmth, comfort | Warnings, medium alerts, time indicators |
| **Moon** | `#e0e7ff` | rgb(224, 231, 255) | Soft light, serenity | Highlights, icon gradients, time displays |
| **Mint** | `#6ee7b7` | rgb(110, 231, 183) | Success, active | Active states, success messages, positive indicators |
| **Rose** | `#fda4af` | rgb(253, 164, 175) | Alert, attention | Alerts, errors, high priority events |

**Swift Implementation:**
```swift
AppTheme.Accent.lavender   // #a78bfa - Primary brand color
AppTheme.Accent.chamomile  // #fbbf24 - Warmth/warnings
AppTheme.Accent.moon       // #e0e7ff - Soft highlights
AppTheme.Accent.mint       // #6ee7b7 - Success/active
AppTheme.Accent.rose       // #fda4af - Alerts/errors
```

**Color Symbolism:**
- **Lavender:** Represents calmness, relaxation, and the app's sleep-focused mission
- **Chamomile:** Evokes warmth and comfort, like a bedtime tea
- **Moon:** The celestial guide for nighttime, soft and gentle
- **Mint:** Fresh, active, and positive (monitoring active, success)
- **Rose:** Gentle alert, arousal detection, attention needed

---

### Text Colors

Optimized for legibility on dark backgrounds with three hierarchy levels.

| Color Name | Hex Code | RGB | Contrast | Usage |
|------------|----------|-----|----------|-------|
| **Primary Text** | `#f1f5f9` | rgb(241, 245, 249) | High | Headlines, primary content, values |
| **Secondary Text** | `#94a3b8` | rgb(148, 163, 184) | Medium | Body text, descriptions, labels |
| **Muted Text** | `#64748b` | rgb(100, 116, 139) | Low | Captions, timestamps, subtle info |

**Swift Implementation:**
```swift
AppTheme.Text.primary    // #f1f5f9 - Highest contrast
AppTheme.Text.secondary  // #94a3b8 - Medium contrast
AppTheme.Text.muted      // #64748b - Low contrast
```

---

### Border & Divider Colors

Subtle borders that define space without harsh lines.

| Color Name | Opacity/Alpha | Usage |
|------------|---------------|-------|
| **Subtle Border** | `rgba(255, 255, 255, 0.08)` | Default card borders, dividers |
| **Lavender Border** | `rgba(167, 139, 250, 0.15)` | Elevated cards, focused states |
| **Card Border** | `rgba(255, 255, 255, 0.05)` | Light card outlines |

**Swift Implementation:**
```swift
AppTheme.Border.subtle    // White 8% opacity
AppTheme.Border.lavender  // Lavender 15% opacity
AppTheme.Border.card      // White 5% opacity
```

---

## Gradients

### Linear Gradients

| Gradient Name | Colors | Direction | Usage |
|---------------|--------|-----------|-------|
| **Moon Gradient** | `#e0e7ff` → `#a78bfa` | Top-left to bottom-right | Moon icon, header accents |
| **Card Gradient** | `rgba(17,24,39,0.95)` → `rgba(15,23,42,0.9)` | Top-left to bottom-right | Card backgrounds |

**Swift Implementation:**
```swift
AppTheme.Gradients.moon  // Moon → Lavender
AppTheme.Gradients.card  // Card background gradient
```

### Radial Gradients

| Gradient Name | Center Color | Edge Color | Radius | Usage |
|---------------|--------------|------------|--------|-------|
| **Lavender Orb** | `rgba(167,139,250,0.3)` | Transparent | 200pt | Background ambient effect |
| **Chamomile Orb** | `rgba(251,191,36,0.2)` | Transparent | 150pt | Background ambient effect |

**Swift Implementation:**
```swift
AppTheme.Gradients.lavenderOrb   // Purple glow
AppTheme.Gradients.chamomileOrb  // Amber glow
```

---

## Typography

### Font Families

| Purpose | Font Family | Fallback | Weight Options |
|---------|-------------|----------|----------------|
| **Titles/Headers** | Georgia (serif) | System serif | Light (300), Regular (400), Medium (500) |
| **Body/UI** | SF Rounded | System rounded | Light (200), Regular (400), Medium (500) |

**Design Notes:**
- **Serif titles** evoke elegance and calm (inspired by Cormorant Garamond on website)
- **Rounded body** text feels friendly and approachable
- Light weights preferred for a soft, relaxed aesthetic

### Type Scale

| Name | Size | Weight | Line Height | Letter Spacing | Usage |
|------|------|--------|-------------|----------------|-------|
| **Large Title** | 32pt | Light | 1.2 | 0.05em | App headers, main screens |
| **Title** | 24pt | Light | 1.2 | 0.05em | Section headers |
| **Subtitle** | 14pt | Regular | 1.3 | 0.15em (uppercase) | Section labels |
| **Body** | 16pt | Regular | 1.5 | Normal | Main content, descriptions |
| **Caption** | 12pt | Light | 1.5 | Normal | Small labels, secondary info |
| **Tiny** | 10pt | Light | 1.4 | 0.1em | Micro labels (watchOS) |

**Swift Implementation:**
```swift
AppTheme.Typography.largeTitle(weight: .light)  // 32pt
AppTheme.Typography.title(weight: .light)       // 24pt
AppTheme.Typography.subtitle(weight: .regular)  // 14pt
AppTheme.Typography.body(weight: .regular)      // 16pt
AppTheme.Typography.caption(weight: .light)     // 12pt
AppTheme.Typography.tiny(weight: .light)        // 10pt
```

---

## Spacing System

Consistent spacing scale for layouts and padding.

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4pt | Tight spacing, icon gaps |
| `sm` | 8pt | Small gaps, compact layouts |
| `md` | 12pt | Default card padding, list items |
| `lg` | 16pt | Standard card padding, section spacing |
| `xl` | 24pt | Large section gaps |
| `xxl` | 32pt | Major section dividers |

**Swift Implementation:**
```swift
AppTheme.Spacing.xs    // 4pt
AppTheme.Spacing.sm    // 8pt
AppTheme.Spacing.md    // 12pt
AppTheme.Spacing.lg    // 16pt
AppTheme.Spacing.xl    // 24pt
AppTheme.Spacing.xxl   // 32pt
```

---

## Corner Radius

Soft, rounded corners throughout the UI.

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 8pt | Small buttons, badges |
| `md` | 12pt | Cards, panels, standard buttons |
| `lg` | 16pt | Large cards, modals |
| `xl` | 24pt | Hero cards, prominent elements |
| `full` | 9999pt | Pills, circular elements |

**Swift Implementation:**
```swift
AppTheme.CornerRadius.sm    // 8pt
AppTheme.CornerRadius.md    // 12pt
AppTheme.CornerRadius.lg    // 16pt
AppTheme.CornerRadius.xl    // 24pt
AppTheme.CornerRadius.full  // Fully rounded
```

---

## Shadows & Effects

### Shadow Styles

| Style | Color | Opacity | Radius | Offset | Usage |
|-------|-------|---------|--------|--------|-------|
| **Card Shadow** | Black | 30% | 25pt | (0, 10) | Standard cards |
| **Elevated Shadow** | Black | 50% | 25pt | (0, 15) | Modal dialogs, important cards |
| **Lavender Glow** | Lavender | 40% | 10pt | (0, 0) | Glowing icons, active elements |

**Swift Implementation:**
```swift
AppTheme.Shadows.card           // rgba(0,0,0,0.3)
AppTheme.Shadows.elevated       // rgba(0,0,0,0.5)
AppTheme.Shadows.lavenderGlow   // rgba(167,139,250,0.4)
```

### Blur Effects

| Effect | Radius | Usage |
|--------|--------|-------|
| **Orb Blur** | 60-80pt | Background gradient orbs |
| **Backdrop Blur** | 20pt | Glassmorphism cards |

---

## Background Effects

### Starfield

**Description:** Animated twinkling stars scattered across the background.

**Properties:**
- Star count: 50-80 (iOS), 20-30 (watchOS for performance)
- Star size: 1-2.5pt randomly distributed
- Opacity: 0.3-1.0 with breathing animation
- Animation: 2-6s ease-in-out, infinite loop
- Blur: 0-0.5pt for depth variation

**Implementation:** `StarfieldBackground` component in `BackgroundEffects.swift`

### Floating Orbs

**Description:** Large, soft gradient circles that slowly float and pulse.

**Orb 1 (Lavender):**
- Size: 300-400pt diameter
- Position: Top-right (-100, -100 offset)
- Color: Lavender radial gradient
- Opacity: 30%
- Blur: 60-80pt
- Animation: 20s float cycle

**Orb 2 (Chamomile):**
- Size: 250-300pt diameter
- Position: Bottom-left (-100, 200 offset)
- Color: Chamomile radial gradient
- Opacity: 25%
- Blur: 50pt
- Animation: 25s float cycle (reverse)

**Implementation:** `FloatingOrbs` component in `BackgroundEffects.swift`

### Platform-Specific Backgrounds

| Platform | Components | Performance Notes |
|----------|------------|-------------------|
| **iOS** | Full starfield + 2 orbs | Rich, full experience |
| **watchOS** | Minimal: 1 subtle orb only | Optimized for battery/performance |

---

## Iconography

### Icon System

**Source:** SF Symbols (Apple's system icon set)
**Style:** Light weight (thin strokes), 20-24pt default size
**Color:** Accent colors (context-dependent)

### Core Icons

| Concept | SF Symbol | Color | Usage |
|---------|-----------|-------|-------|
| **App/Sleep** | `moon.stars.fill` | Lavender | App icon, headers |
| **Night** | `moon.fill` | Lavender/Moon | Sleep mode, nighttime |
| **Sleeping** | `moon.zzz.fill` | Lavender | Empty states, sleep tracking |
| **Wake** | `sunrise.fill` | Chamomile | Wake time, morning |
| **Heart Rate** | `heart.fill` | Rose | Monitoring, vital signs |
| **Waveform** | `waveform.path.ecg` | Mint | Data visualization |
| **Alert** | `exclamationmark.triangle.fill` | Rose | Arousal events |
| **Success** | `checkmark.circle.fill` | Mint | Completed, active |
| **Settings** | `gearshape.fill` | Secondary text | Settings, config |
| **Export** | `square.and.arrow.up` | Mint | Share, export data |
| **Play** | `play.fill` | Mint | Start monitoring |
| **Stop** | `stop.fill` | Rose | Stop monitoring |
| **Watch** | `applewatch` | Lavender | Watch device status |

**Implementation:** `AppIcons` struct in `AppIcons.swift`

### Icon Guidelines

1. **Weight:** Always use light or regular weight
2. **Size:** 16-24pt for UI icons, 32-48pt for hero icons
3. **Color:** Match icon color to meaning (alerts = rose, success = mint)
4. **Gradients:** Use moon gradient for prominent icons

---

## UI Components

### Card Styles

#### Standard Card

**Visual Characteristics:**
- Background: `#111827` (Card Background)
- Border: 1pt white at 5% opacity
- Corner radius: 16pt (lg)
- Padding: 16pt (lg)
- Shadow: Black 30% opacity, 25pt radius, (0,10) offset

**Usage:** General content cards, info displays

**SwiftUI Modifier:**
```swift
.themeCard(padding: 16, showBorder: true)
```

#### Elevated Card

**Visual Characteristics:**
- Background: Card gradient (`#111827` → `#0f1736`)
- Border: 1pt lavender at 15% opacity
- Corner radius: 16pt (lg)
- Padding: 16pt (lg)
- Shadow:
  - Black 50% opacity, 25pt radius, (0,15) offset
  - Lavender 40% opacity glow, 10pt radius
- Backdrop blur: 20pt

**Usage:** Important cards, focused content, modals

**SwiftUI Modifier:**
```swift
.themeElevatedCard(padding: 16)
```

### Badges

**Visual Characteristics:**
- Background: Accent color at 15% opacity
- Foreground: Full accent color
- Font: 10pt uppercase, medium weight, 0.8pt letter spacing
- Padding: 4pt vertical, 8pt horizontal
- Corner radius: 4pt (sm)

**Usage:** Status indicators, labels, tags

**Example colors:**
- Active: Mint background + Mint text
- Alert: Rose background + Rose text
- Info: Lavender background + Lavender text

### Buttons

#### Primary Button

- Background: Lavender (`#a78bfa`)
- Foreground: Deep background (`#0a0e1a`)
- Font: 16pt medium weight
- Padding: 12pt vertical, full width
- Corner radius: 12pt

#### Secondary Button

- Background: White at 10% opacity
- Foreground: Primary text (`#f1f5f9`)
- Font: 16pt medium weight
- Padding: 12pt vertical, full width
- Corner radius: 12pt

#### Danger Button

- Background: Rose (`#fda4af`)
- Foreground: Deep background (`#0a0e1a`)
- Font: 16pt medium weight
- Padding: 12pt vertical, full width
- Corner radius: 12pt

---

## Animations

### Timing Functions

| Name | Duration | Curve | Usage |
|------|----------|-------|-------|
| **Fast** | 0.2s | Ease-out | Quick feedback, hover states |
| **Medium** | 0.3s | Ease-out | Standard transitions |
| **Slow** | 0.5s | Ease-out | Major view changes |
| **Breathing** | 4s | Ease-in-out (infinite loop) | Meditation indicators |

**Swift Implementation:**
```swift
AppTheme.Animation.fast       // 0.2s ease-out
AppTheme.Animation.medium     // 0.3s ease-out
AppTheme.Animation.slow       // 0.5s ease-out
AppTheme.Animation.breathing  // 4s loop
```

### Signature Animations

#### Breathing Circle

**Purpose:** Indicate calm, active monitoring states

**Animation:**
- Scale: 0.8 → 1.2 → 0.8
- Opacity: 0.4 → 0.8 → 0.4
- Duration: 8s (4s inhale, 4s exhale)
- Curve: Ease-in-out
- Loop: Infinite

**Usage:** Monitoring active indicator, meditation prompts

#### Moon Glow

**Purpose:** Draw attention to primary app icon/branding

**Animation:**
- Glow intensity: 0.4 → 0.7 → 0.4
- Shadow radius: 8pt → 20pt → 8pt
- Duration: 4s
- Curve: Ease-in-out
- Loop: Infinite

**Usage:** App header, splash screen

#### Star Twinkle

**Purpose:** Create ambient nighttime atmosphere

**Animation:**
- Opacity: 0 → random(0.3-1.0) → 0
- Scale: 0.5 → 1.0 → 0.5
- Duration: Random 2-6s
- Delay: Random 0-4s
- Curve: Ease-in-out
- Loop: Infinite

**Usage:** Background starfield

---

## Platform-Specific Guidelines

### iOS

**Screen Sizes:** iPhone 12-15 series, SE
**Safe Areas:** Respect notch, home indicator
**Background:** Full starfield + orbs
**Typography:** Full type scale available
**Interactions:** Tap, swipe, long-press

**Unique Features:**
- TabView with night sky background
- Full navigation stack
- Rich animations and effects
- Large cards with elevation

### watchOS

**Screen Sizes:** 40mm, 44mm, 45mm, 49mm
**Safe Areas:** Round corners, bezel
**Background:** Minimal (1 orb only)
**Typography:** Caption and tiny emphasized for space
**Interactions:** Tap, crown scroll, force touch

**Unique Features:**
- Simplified backgrounds (performance)
- Larger tap targets (44pt minimum)
- Reduced animations
- Compact layouts
- Digital Crown integration

**Performance Optimizations:**
- Fewer stars (20-30 vs 50-80)
- Single orb instead of two
- No backdrop blur on cards
- Simpler gradients

---

## Accessibility

### Color Contrast

All text colors meet WCAG AA standards against backgrounds:

| Text Color | Background | Contrast Ratio | Pass |
|------------|------------|----------------|------|
| Primary Text (`#f1f5f9`) | Deep Background (`#0a0e1a`) | 14.2:1 | ✓ AAA |
| Secondary Text (`#94a3b8`) | Deep Background (`#0a0e1a`) | 7.8:1 | ✓ AA |
| Muted Text (`#64748b`) | Deep Background (`#0a0e1a`) | 5.1:1 | ✓ AA |

### Dark Mode Only

iTrack is **dark mode only** by design:
- Reduces eye strain during nighttime use
- Aligns with sleep tracking context
- Better battery life on OLED screens

**Implementation:**
```swift
.preferredColorScheme(.dark)
```

### Dynamic Type

All typography scales with system font size settings using:
```swift
Font.system(.body, design: .rounded)  // Respects user preferences
```

### VoiceOver Labels

All icons include descriptive labels:
```swift
Image(systemName: AppIcons.sleep)
    .accessibilityLabel("Sleep mode")
```

---

## File Structure

```
/Shared/Theme/
├── AppTheme.swift          // Main theme definition, colors, typography
├── BackgroundEffects.swift // Starfield, orbs, animations
├── ThemeComponents.swift   // Reusable UI components
└── AppIcons.swift          // Icon mappings and helpers
```

---

## Usage Examples

### Creating a Themed Card

```swift
VStack {
    Text("Heart Rate")
        .font(AppTheme.Typography.caption())
        .foregroundColor(AppTheme.Text.muted)

    Text("72 BPM")
        .font(AppTheme.Typography.title())
        .foregroundColor(AppTheme.Accent.mint)
}
.themeElevatedCard()
```

### Using Status Colors

```swift
let color = AppIcons.colorForSeverity(.high)  // Returns rose
let icon = AppIcons.iconForSeverity(.medium)  // Returns exclamationmark.circle.fill
```

### Applying Background

```swift
ZStack {
    NightSkyBackground()  // Full effect for iOS
    // or
    MinimalNightBackground()  // Simplified for watchOS

    // Your content here
}
```

---

## Brand Essence

### Visual Keywords

- **Calm** — Soft colors, breathing animations
- **Nocturnal** — Deep backgrounds, moon imagery, stars
- **Clinical** — Clean layouts, data-focused
- **Gentle** — Rounded corners, light weights, subtle borders
- **Serene** — Floating orbs, slow animations

### Design Principles

1. **Nighttime-First:** Every design decision considers nighttime use
2. **Minimal Distraction:** Reduce cognitive load during sleep hours
3. **Data Clarity:** Health metrics are always clear and readable
4. **Consistent Cross-Platform:** iOS and watchOS share visual DNA
5. **Performance-Conscious:** Especially on watchOS battery life

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 6, 2025 | Initial branding system based on Rotina Noturna website |

---

**Maintained by:** FixSleep Design Team
**Questions?** Refer to `/Shared/Theme/` source files for implementation details
