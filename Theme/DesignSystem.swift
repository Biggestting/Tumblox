import SwiftUI

// MARK: - Brand Color Tokens

extension Color {
    // Primary gradient (extracted from Tumblox app icon)
    static let primaryGradientStart = Color(hex: "#8B5CF6")  // purple
    static let primaryGradientMid   = Color(hex: "#EC4899")  // pink / coral
    static let primaryGradientEnd   = Color(hex: "#F97316")  // orange

    // Light-mode surfaces
    static let backgroundPrimary   = Color(hex: "#F6F5F8")   // soft warm off-white
    static let cardBackground      = Color(hex: "#FFFFFF")    // white card
    static let surfaceElevated     = Color(hex: "#EEEDF2")   // HUD / control bar
    static let boardSurface        = Color(hex: "#EFEEF3")   // game board

    // Light-mode text
    static let textPrimaryLight    = Color(hex: "#1A1A2E")   // near-black, warm
    static let textSecondaryLight  = Color(hex: "#6B7280")   // muted gray
    static let textMutedLight      = Color(hex: "#9CA3AF")   // light gray

    // Light-mode divider
    static let dividerLight        = Color(hex: "#E5E7EB")   // subtle neutral
}

// MARK: - Gradients

enum TumbloxGradient {
    /// Full brand gradient — purple → pink → orange (leading → trailing)
    static let primary = LinearGradient(
        colors: [.primaryGradientStart, .primaryGradientMid, .primaryGradientEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Short accent gradient — pink → orange (for small elements)
    static let accent = LinearGradient(
        colors: [.primaryGradientMid, .primaryGradientEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Vertical variant for overlays
    static let vertical = LinearGradient(
        colors: [.primaryGradientStart, .primaryGradientMid, .primaryGradientEnd],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Design System Constants

typealias DS = DesignSystem

enum DesignSystem {
    // MARK: Spacing (8pt grid)
    static let spacingXS:  CGFloat = 4
    static let spacingSM:  CGFloat = 8
    static let spacingMD:  CGFloat = 12
    static let spacingLG:  CGFloat = 16
    static let spacingXL:  CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // MARK: Corner Radius
    static let radiusSM:  CGFloat = 8
    static let radiusMD:  CGFloat = 12
    static let radiusLG:  CGFloat = 16
    static let radiusXL:  CGFloat = 20

    // MARK: Card Shadow (light mode only)
    static let shadowColor   = Color.black.opacity(0.04)
    static let shadowRadius: CGFloat = 8
    static let shadowY:      CGFloat = 2

    // MARK: CTA Button Shadow
    static let ctaShadowColor   = Color.primaryGradientMid.opacity(0.3)
    static let ctaShadowRadius: CGFloat = 8
    static let ctaShadowY:      CGFloat = 4
}
