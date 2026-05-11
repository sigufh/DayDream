import Foundation

enum ArtStyle: String, Codable, CaseIterable, Identifiable {
    case impressionist
    case japaneseAesthetic
    case surreal
    case romantic
    case minimalist
    case inkWash

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .impressionist:
            return "印象派"
        case .japaneseAesthetic:
            return "日系美学"
        case .surreal:
            return "超现实"
        case .romantic:
            return "浪漫主义"
        case .minimalist:
            return "极简主义"
        case .inkWash:
            return "水墨"
        }
    }

    var description: String {
        SkillRegistry.styleSkill(for: self).definition.description
    }

    var icon: String {
        SkillRegistry.styleSkill(for: self).icon
    }

    /// 诗歌风格指引 —— 告诉 AI 针对这个艺术风格应该用什么诗歌语言
    var poemStyleGuide: String {
        SkillRegistry.styleSkill(for: self).poemStyleGuide
    }
}
