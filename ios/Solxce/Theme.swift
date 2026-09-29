// Theme.swift
import SwiftUI

/// Athletic Volt Design System tokens for Solxce
/// Selected palette: Primary #D4FF3F (Volt), Accent #FF3B5C (Crimson), Background #0A0A0A (Dark Ground)
/// Surface #161616, Text #F5F5F5
enum AppTheme {
    // MARK: - Colors
    static let primary = Color(red: 0.831, green: 1.0, blue: 0.247) // #D4FF3F Volt
    static let accent = Color(red: 1.0, green: 0.231, blue: 0.361)  // #FF3B5C Crimson
    static let ground = Color(red: 0.039, green: 0.039, blue: 0.039) // #0A0A0A Dark Ground
    static let surface = Color(red: 0.086, green: 0.086, blue: 0.086) // #161616 Card Surface
    static let surfaceRaised = Color(red: 0.125, green: 0.125, blue: 0.125) // #202020
    static let field = Color(red: 0.149, green: 0.149, blue: 0.149) // #262626 Input Fields
    static let hairline = Color.white.opacity(0.10)
    static let text = Color(red: 0.96, green: 0.96, blue: 0.96) // #F5F5F5
    static let textSecondary = Color(red: 0.65, green: 0.65, blue: 0.65)
    static let textMuted = Color(red: 0.45, green: 0.45, blue: 0.45)
    static let onPrimary = Color.black // High contrast on volt

    // MARK: - Macros Semantics
    static let caloriesColor = Color(red: 0.831, green: 1.0, blue: 0.247) // Volt
    static let proteinColor = Color(red: 1.0, green: 0.231, blue: 0.361)  // Crimson
    static let carbsColor = Color(red: 0.235, green: 0.702, blue: 1.0)    // Sky Blue
    static let fatColor = Color(red: 1.0, green: 0.757, blue: 0.027)      // Amber

    // MARK: - Spacing Grid
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let huge: CGFloat = 48
        static let screenMargin: CGFloat = 16
    }

    // MARK: - Radii
    enum Radii {
        static let button: CGFloat = 12
        static let card: CGFloat = 14
        static let sheet: CGFloat = 20
        static let tag: CGFloat = 8
    }

    // MARK: - Typographic Ramp
    static let displayFont: Font = .system(size: 32, weight: .black, design: .default)
    static let heroNumeralFont: Font = .system(size: 44, weight: .black, design: .rounded)
    static let largeTitleFont: Font = .system(size: 28, weight: .bold, design: .default)
    static let titleFont: Font = .system(size: 20, weight: .bold, design: .default)
    static let headlineFont: Font = .system(size: 17, weight: .semibold, design: .default)
    static let bodyFont: Font = .system(size: 16, weight: .regular, design: .default)
    static let subheadlineFont: Font = .system(size: 14, weight: .medium, design: .default)
    static let captionFont: Font = .system(size: 12, weight: .regular, design: .default)
    static let eyebrowFont: Font = .system(size: 11, weight: .bold, design: .default)
}
