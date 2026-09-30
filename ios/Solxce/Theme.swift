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

/// Athletic Volt Design System tokens for Solxce
/// Adaptive tokens support both Dark and Light modes while preserving high-energy Volt accents and crisp readability.
public enum AppTheme {
    // MARK: - Adaptive Color Helper
    public static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }

    // MARK: - Core Colors
    /// High-energy Volt accent: slightly deeper in light mode (#1B9E00 or #A3D900 / #0E7C00) for contrast, bright Volt (#D4FF3F) in dark mode
    public static let primary = dynamicColor(
        light: UIColor(red: 0.16, green: 0.65, blue: 0.05, alpha: 1.0), // Deep Athletic Green/Volt on light
        dark: UIColor(red: 0.831, green: 1.0, blue: 0.247, alpha: 1.0)  // #D4FF3F Volt on dark
    )

    public static let primaryVolt = Color(red: 0.831, green: 1.0, blue: 0.247) // Always electric volt

    /// Crimson accent
    public static let accent = dynamicColor(
        light: UIColor(red: 0.90, green: 0.15, blue: 0.28, alpha: 1.0),
        dark: UIColor(red: 1.0, green: 0.231, blue: 0.361, alpha: 1.0)
    )

    /// Base canvas background: Paper White/Soft Gray (#F7F7F8) in light mode, Charcoal Black (#0A0A0A) in dark mode
    public static let ground = dynamicColor(
        light: UIColor(red: 0.965, green: 0.965, blue: 0.975, alpha: 1.0),
        dark: UIColor(red: 0.039, green: 0.039, blue: 0.039, alpha: 1.0)
    )

    /// Card surfaces: Crisp White (#FFFFFF) in light mode, Dark Slate (#161616) in dark mode
    public static let surface = dynamicColor(
        light: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        dark: UIColor(red: 0.086, green: 0.086, blue: 0.086, alpha: 1.0)
    )

    /// Elevated surfaces: Light Gray (#F0F0F3) in light mode, Slate (#202020) in dark mode
    public static let surfaceRaised = dynamicColor(
        light: UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1.0),
        dark: UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.0)
    )

    /// Input fields & subtle chips
    public static let field = dynamicColor(
        light: UIColor(red: 0.90, green: 0.90, blue: 0.93, alpha: 1.0),
        dark: UIColor(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
    )

    /// Hairline borders
    public static let hairline = dynamicColor(
        light: UIColor(white: 0.0, alpha: 0.08),
        dark: UIColor(white: 1.0, alpha: 0.10)
    )

    /// Primary Typography: Near Black (#111113) in light mode, Near White (#F5F5F5) in dark mode
    public static let text = dynamicColor(
        light: UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1.0),
        dark: UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    )

    /// Secondary Typography: Muted Charcoal (#686872) in light mode, Soft Silver (#A6A6A6) in dark mode
    public static let textSecondary = dynamicColor(
        light: UIColor(red: 0.42, green: 0.42, blue: 0.48, alpha: 1.0),
        dark: UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.0)
    )

    /// Muted/Disabled Typography
    public static let textMuted = dynamicColor(
        light: UIColor(red: 0.62, green: 0.62, blue: 0.68, alpha: 1.0),
        dark: UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0)
    )

    /// Text sitting on top of primary button
    public static let onPrimary = dynamicColor(
        light: UIColor.white,
        dark: UIColor.black
    )

    // MARK: - Macros Semantics
    public static let caloriesColor = dynamicColor(
        light: UIColor(red: 0.16, green: 0.65, blue: 0.05, alpha: 1.0),
        dark: UIColor(red: 0.831, green: 1.0, blue: 0.247, alpha: 1.0)
    )
    public static let proteinColor = dynamicColor(
        light: UIColor(red: 0.88, green: 0.12, blue: 0.25, alpha: 1.0),
        dark: UIColor(red: 1.0, green: 0.231, blue: 0.361, alpha: 1.0)
    )
    public static let carbsColor = dynamicColor(
        light: UIColor(red: 0.05, green: 0.50, blue: 0.90, alpha: 1.0),
        dark: UIColor(red: 0.235, green: 0.702, blue: 1.0, alpha: 1.0)
    )
    public static let fatColor = dynamicColor(
        light: UIColor(red: 0.90, green: 0.60, blue: 0.0, alpha: 1.0),
        dark: UIColor(red: 1.0, green: 0.757, blue: 0.027, alpha: 1.0)
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
