import Foundation

enum ArtStyle: String, CaseIterable, Identifiable {
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
        switch self {
        case .impressionist:
            return "经典印象派油画风格，可见笔触，光影变化"
        case .japaneseAesthetic:
            return "日系美学，柔焦背景，细腻柔和的氛围"
        case .surreal:
            return "超现实主义，梦幻奇异，打破现实边界"
        case .romantic:
            return "浪漫主义，情感丰富，戏剧性光影"
        case .minimalist:
            return "极简主义，简洁构图，留白艺术"
        case .inkWash:
            return "中国水墨画，写意泼墨，气韵生动"
        }
    }

    var icon: String {
        switch self {
        case .impressionist:
            return "paintpalette"
        case .japaneseAesthetic:
            return "leaf.fill"
        case .surreal:
            return "star.circle.fill"
        case .romantic:
            return "heart.circle.fill"
        case .minimalist:
            return "circle.grid.2x2"
        case .inkWash:
            return "paintbrush.pointed.fill"
        }
    }

    /// 诗歌风格指引 —— 告诉 AI 针对这个艺术风格应该用什么诗歌语言
    var poemStyleGuide: String {
        switch self {
        case .impressionist:
            return "诗歌语言如印象派画风：用光影、色彩、笔触感的意象，句式轻柔流动，像光斑在水面游走。偏向现代朦胧诗。"
        case .japaneseAesthetic:
            return "诗歌语言如日系俳句：极致凝练，捕捉一瞬间的感触，带有物哀之美（mono no aware），语调克制含蓄，留白多于倾诉。"
        case .surreal:
            return "诗歌语言如超现实画作：大胆拼接不相关的意象，跳跃、荒诞、出其不意，像梦中逻辑一样自然流畅。"
        case .romantic:
            return "诗歌语言如浪漫主义：情感浓烈外放，用自然景观映射内心，修辞华丽，有戏剧性的张力和崇高感。"
        case .minimalist:
            return "诗歌语言如极简主义：字数极少，每个字都不可删减，大量留白，一句话承载整首诗的重量。"
        case .inkWash:
            return "诗歌语言如水墨画：古典中文意境，用山水、烟雨、松竹等传统意象，句式参照古诗词韵律，淡墨浓情，意在画外。"
        }
    }
}
