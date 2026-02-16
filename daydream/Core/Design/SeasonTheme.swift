import SwiftUI

enum Season: String, CaseIterable, Identifiable {
    case spring
    case summer
    case autumn
    case winter

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .spring: return "春"
        case .summer: return "夏"
        case .autumn: return "秋"
        case .winter: return "冬"
        }
    }

    var displayNameEN: String {
        switch self {
        case .spring: return "Spring"
        case .summer: return "Summer"
        case .autumn: return "Autumn"
        case .winter: return "Winter"
        }
    }

    var gradient: [Color] {
        switch self {
        case .spring:
            return [Color(hex: "E8F5E9"), Color(hex: "A5D6A7"), Color(hex: "F8BBD0")]
        case .summer:
            return [Color(hex: "E8F5E9"), Color(hex: "AED581"), Color(hex: "FFF176")]
        case .autumn:
            return [Color(hex: "FFF8E1"), Color(hex: "FFCC80"), Color(hex: "E57373")]
        case .winter:
            return [Color(hex: "ECEFF1"), Color(hex: "90A4AE"), Color(hex: "5C6BC0")]
        }
    }

    var linearGradient: LinearGradient {
        LinearGradient(
            colors: gradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var current: Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5:  return .spring
        case 6...8:  return .summer
        case 9...11: return .autumn
        default:     return .winter
        }
    }
}
