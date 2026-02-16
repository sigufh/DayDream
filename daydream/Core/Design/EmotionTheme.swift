import SwiftUI

enum DreamEmotion: String, Codable, CaseIterable, Identifiable {
    case serenity
    case melancholy
    case anxiety
    case hope
    case whimsy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .serenity:   return "宁静"
        case .melancholy: return "忧郁"
        case .anxiety:    return "焦虑"
        case .hope:       return "希望"
        case .whimsy:     return "奇幻"
        }
    }

    var displayNameEN: String {
        switch self {
        case .serenity:   return "Serenity"
        case .melancholy: return "Melancholy"
        case .anxiety:    return "Anxiety"
        case .hope:       return "Hope"
        case .whimsy:     return "Whimsy"
        }
    }

    var gradient: [Color] {
        switch self {
        case .serenity:
            return [Color(hex: "E0F7FA"), Color(hex: "80DEEA"), Color(hex: "00897B")]
        case .melancholy:
            return [Color(hex: "EDE7F6"), Color(hex: "B39DDB"), Color(hex: "4527A0")]
        case .anxiety:
            return [Color(hex: "FFF3E0"), Color(hex: "FFB74D"), Color(hex: "E65100")]
        case .hope:
            return [Color(hex: "FFF9C4"), Color(hex: "FFD54F"), Color(hex: "FF8F00")]
        case .whimsy:
            return [Color(hex: "F3E5F5"), Color(hex: "CE93D8"), Color(hex: "6A1B9A")]
        }
    }

    var linearGradient: LinearGradient {
        LinearGradient(
            colors: gradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var primaryColor: Color {
        gradient[1]
    }
}
