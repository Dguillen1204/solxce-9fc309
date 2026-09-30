// Theme.swift
import SwiftUI
import UIKit

/// Appearance selection setting persisted in AppStorage
public enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "system"
    case dark = "dark"
    case light = "light"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .system: return "System"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }

    public var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .dark: return "moon.stars.fill"
        case .light: return "sun.max.fill"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
}

/// Apex Volt & Neon Lime Design System tokens for Solxce (Whoop / Apex Telemetry aesthetic)
/// Pitch-black obsidian canvas, crisp specular white primary, electric kinetic volt accents (#CCFF00 / #A3E635), and deep charcoal surfaces.
public enum AppTheme {
    // MARK: - Adaptive Color Helper
    public static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }

    // MARK: - Core Colors (Apex Volt & Neon Lime)
    /// Primary Specular White (#FFFFFF)
    public static let primary = dynamicColor(
        light: UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1.0),
        dark: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // #FFFFFF
    )

    /// Apex Volt accent (#CCFF00 / Electric Volt)
    public static let accent = dynamicColor(
        light: UIColor(red: 0.52, green: 0.72, blue: 0.0, alpha: 1.0), // Deep volt for light mode
        dark: UIColor(red: 0.800, green: 1.000, blue: 0.000, alpha: 1.0) // #CCFF00 Hyper Volt
    )

    /// Electric Volt & Platinum highlight tokens
    public static let volt = Color(red: 0.800, green: 1.000, blue: 0.000) // #CCFF00
    public static let neonLime = Color(red: 0.639, green: 0.902, blue: 0.208) // #A3E635
    public static let crimson = Color(red: 0.937, green: 0.267, blue: 0.267) // #EF4444 (for zone alerts)
    public static let platinum = Color(red: 0.886, green: 0.910, blue: 0.941) // #E2E8F0
    public static let primaryVolt = volt // Compatibility alias

    /// Base canvas background: True Black (#000000)
    public static let ground = dynamicColor(
        light: UIColor(red: 0.965, green: 0.965, blue: 0.975, alpha: 1.0),
        dark: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // #000000
    )

    /// Card surfaces: Deep Obsidian (#121212)
    public static let surface = dynamicColor(
        light: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        dark: UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1.0) // #121212
    )

    /// Elevated surfaces: Refined Charcoal (#1C1C1C)
    public static let surfaceRaised = dynamicColor(
        light: UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1.0),
        dark: UIColor(red: 0.110, green: 0.110, blue: 0.110, alpha: 1.0) // #1C1C1C
    )

    /// Input fields & subtle chips (#222224)
    public static let field = dynamicColor(
        light: UIColor(red: 0.90, green: 0.90, blue: 0.93, alpha: 1.0),
        dark: UIColor(red: 0.133, green: 0.133, blue: 0.141, alpha: 1.0)
    )

    /// Hairline borders (Specular platinum / volt shimmer)
    public static let hairline = dynamicColor(
        light: UIColor(white: 0.0, alpha: 0.08),
        dark: UIColor(white: 1.0, alpha: 0.12)
    )

    /// Primary Typography: High Contrast White (#FFFFFF)
    public static let text = dynamicColor(
        light: UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1.0),
        dark: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // #FFFFFF
    )

    /// Secondary Typography: Platinum Muted (#94A3B8 / #CBD5E1)
    public static let textSecondary = dynamicColor(
        light: UIColor(red: 0.42, green: 0.42, blue: 0.48, alpha: 1.0),
        dark: UIColor(red: 0.65, green: 0.67, blue: 0.72, alpha: 1.0)
    )

    /// Muted/Disabled Typography (#64748B)
    public static let textMuted = dynamicColor(
        light: UIColor(red: 0.62, green: 0.62, blue: 0.68, alpha: 1.0),
        dark: UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0)
    )

    /// Text sitting on top of primary button
    public static let onPrimary = dynamicColor(
        light: UIColor.white,
        dark: UIColor.black
    )

    // MARK: - Telemetry & Macro Semantics (Apex Volt / Telemetry Ramp)
    public static let caloriesColor = dynamicColor(
        light: UIColor(red: 0.52, green: 0.72, blue: 0.0, alpha: 1.0),
        dark: UIColor(red: 0.800, green: 1.000, blue: 0.000, alpha: 1.0) // Hyper Volt #CCFF00
    )
    public static let proteinColor = dynamicColor(
        light: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0),
        dark: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // Specular White
    )
    public static let carbsColor = dynamicColor(
        light: UIColor(red: 0.35, green: 0.37, blue: 0.42, alpha: 1.0),
        dark: UIColor(red: 0.639, green: 0.902, blue: 0.208, alpha: 1.0) // Neon Lime #A3E635
    )
    public static let fatColor = dynamicColor(
        light: UIColor(red: 0.55, green: 0.58, blue: 0.65, alpha: 1.0),
        dark: UIColor(red: 0.45, green: 0.49, blue: 0.56, alpha: 1.0) // Charcoal Steel
    )

    // MARK: - Spacing Grid
    public enum Spacing {
        public static let xxs: CGFloat = 4
        public static let xs: CGFloat = 8
        public static let sm: CGFloat = 12
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 20
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
        public static let huge: CGFloat = 48
        public static let screenMargin: CGFloat = 16
    }

    // MARK: - Radii
    public enum Radii {
        public static let button: CGFloat = 12
        public static let card: CGFloat = 14
        public static let sheet: CGFloat = 20
        public static let tag: CGFloat = 8
    }

    // MARK: - Typographic Ramp
    public static let displayFont: Font = .system(size: 32, weight: .black, design: .default)
    public static let heroNumeralFont: Font = .system(size: 44, weight: .black, design: .rounded)
    public static let largeTitleFont: Font = .system(size: 28, weight: .bold, design: .default)
    public static let titleFont: Font = .system(size: 20, weight: .bold, design: .default)
    public static let headlineFont: Font = .system(size: 17, weight: .semibold, design: .default)
    public static let bodyFont: Font = .system(size: 16, weight: .regular, design: .default)
    public static let subheadlineFont: Font = .system(size: 14, weight: .medium, design: .default)
    public static let captionFont: Font = .system(size: 12, weight: .regular, design: .default)
    public static let eyebrowFont: Font = .system(size: 11, weight: .bold, design: .default)
    public static let monoFont: Font = .system(size: 13, weight: .semibold, design: .monospaced)
}

// MARK: - Color Hex Initializer Extension
extension Color {
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
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
