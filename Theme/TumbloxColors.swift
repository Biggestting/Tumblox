import SwiftUI

enum TumbloxColors {
    // MARK: - Raw tokens

    static let accentBar      = Color(hex: "#F5A623")   // gold
    static let accentBarDim   = Color(hex: "#F5A62360")
    static let goldProgress   = Color(hex: "#F5A623")
    static let destructive    = Color(hex: "#FF3B30")
    static let fieldSurface   = Color(hex: "#111111")   // dark card surface
    static let fieldBorder    = Color(white: 1, opacity: 0.10)

    // MARK: - Adaptive helpers

    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.black : Color(hex: "#F7F7F7")
    }

    static func card(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#111111") : Color.white
    }

    static func textPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color(hex: "#0A0A0A")
    }

    static func textSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 1, opacity: 0.55) : Color(white: 0, opacity: 0.45)
    }

    static func textMuted(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 1, opacity: 0.30) : Color(white: 0, opacity: 0.30)
    }

    static func primaryCTA(_ scheme: ColorScheme) -> Color {
        accentBar
    }

    static func divider(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 1, opacity: 0.08) : Color(white: 0, opacity: 0.08)
    }

    static func hudBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#0D0D0D") : Color(hex: "#EFEFEF")
    }

    static func controlBar(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#1A1A1A") : Color(hex: "#E8E8E8")
    }

    static func controlIcon(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color(hex: "#0A0A0A")
    }
}

// MARK: - Color(hex:)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
