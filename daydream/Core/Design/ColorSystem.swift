import SwiftUI

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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

// MARK: - Core Palette

extension Color {
    /// Pearl White #FDFCF8 — primary background
    static let pearlWhite = Color(hex: "FDFCF8")
    /// Twilight Cyan-Blue #1A2A3A — immersive dark background
    static let twilightCyanBlue = Color(hex: "1A2A3A")
    /// Aurora Lavender #D1C4E9 — accent, interactive elements
    static let auroraLavender = Color(hex: "D1C4E9")
    /// Smoky Gray #4A4A4A — body text
    static let smokyGray = Color(hex: "4A4A4A")
}

// MARK: - Derived Palette

extension Color {
    /// Ivory Gray #F2F0E9 — card backgrounds, secondary surfaces
    static let ivoryGray = Color(hex: "F2F0E9")
    /// Glacier Blue #E1F5FE — light accent, calm states
    static let glacierBlue = Color(hex: "E1F5FE")
    /// Misty Blue #B0BEC5 — muted text, watermarks
    static let mistyBlue = Color(hex: "B0BEC5")
    /// Deep Blue-Gray #2C3E50 — dark text on light backgrounds
    static let deepBlueGray = Color(hex: "2C3E50")
    /// Linen #E0E0E0 — dividers, borders
    static let linen = Color(hex: "E0E0E0")
    /// Luminous Pink #F8BBD0 — emotion accent, whimsy
    static let luminousPink = Color(hex: "F8BBD0")
    /// Champagne Gold #FFF9E1 — highlights, hope
    static let champagneGold = Color(hex: "FFF9E1")
    /// Midnight Indigo #4527A0 — deep accent, dream depth
    static let midnightIndigo = Color(hex: "4527A0")
}
