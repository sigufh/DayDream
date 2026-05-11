import Foundation

enum SkillCategory: String, Codable, Hashable {
    case styleProfile
    case retrieval
    case interpretation
    case guidance
}

enum SkillCapability: String, Codable, Hashable {
    case stylePrompting
    case dreamRetrieval
    case tarotRetrieval
    case dreamInterpretation
    case actionGuidance
}

struct SkillDefinition: Identifiable, Codable, Hashable {
    let id: String
    let displayName: String
    let description: String
    let category: SkillCategory
    let capabilities: [SkillCapability]
}

struct SkillReference: Identifiable, Hashable {
    let id: String
    let title: String
    let excerpt: String
    let badge: String
}

struct SkillResult: Hashable {
    let skillID: String
    let title: String
    let content: String
    let references: [SkillReference]
    let metadata: [String: String]
}

struct SkillContext {
    let userInput: String
    let dreams: [Dream]
    let divinations: [Divination]
    let preferredStyleSkillID: String
    let priorResults: [SkillResult]
}

protocol AppSkill {
    var definition: SkillDefinition { get }
    func execute(with context: SkillContext) async -> SkillResult
}

enum StylePromptCapability: String, Codable, Hashable {
    case poem
    case image
    case agent
}

struct StyleSkillPayload: Codable, Hashable {
    let legacyArtStyle: ArtStyle
    let icon: String
    let poemStyleGuide: String
    let imagePromptGuide: String
    let agentInterpretationGuide: String
    let negativePromptGuide: String
}

struct StyleSkillProfile: Identifiable, Codable, Hashable {
    let id: String
    let definition: SkillDefinition
    let payload: StyleSkillPayload

    var legacyArtStyle: ArtStyle { payload.legacyArtStyle }
    var icon: String { payload.icon }
    var poemStyleGuide: String { payload.poemStyleGuide }
    var imagePromptGuide: String { payload.imagePromptGuide }
    var agentInterpretationGuide: String { payload.agentInterpretationGuide }
    var negativePromptGuide: String { payload.negativePromptGuide }

    func promptGuide(for capability: StylePromptCapability) -> String {
        switch capability {
        case .poem:
            return poemStyleGuide
        case .image:
            return imagePromptGuide
        case .agent:
            return agentInterpretationGuide
        }
    }
}

private struct PassiveStyleSkill: AppSkill {
    let profile: StyleSkillProfile

    var definition: SkillDefinition { profile.definition }

    func execute(with context: SkillContext) async -> SkillResult {
        SkillResult(
            skillID: profile.id,
            title: profile.definition.displayName,
            content: profile.agentInterpretationGuide,
            references: [],
            metadata: [
                "category": profile.definition.category.rawValue,
                "legacyArtStyle": profile.legacyArtStyle.rawValue
            ]
        )
    }
}

enum SkillRegistry {
    private static let styleProfiles: [StyleSkillProfile] = [
        StyleSkillProfile(
            id: ArtStyle.impressionist.rawValue,
            definition: SkillDefinition(
                id: ArtStyle.impressionist.rawValue,
                displayName: "印象派",
                description: "经典印象派油画风格，可见笔触，光影变化",
                category: .styleProfile,
                capabilities: [.stylePrompting]
            ),
            payload: StyleSkillPayload(
                legacyArtStyle: .impressionist,
                icon: "paintpalette",
                poemStyleGuide: "诗歌语言如印象派画风：用光影、色彩、笔触感的意象，句式轻柔流动，像光斑在水面游走。偏向现代朦胧诗。",
                imagePromptGuide: "画面强调油画肌理、光影层次、空气感和可见笔触，优先把梦中主体放在自然光或氛围光里，保留朦胧与流动性。",
                agentInterpretationGuide: "解读语气偏柔和、细腻、富有光影感。多用感受与细部观察串联，不要写成硬邦邦分析报告。",
                negativePromptGuide: "避免赛博朋克、硬边 3D、商业海报感、过饱和霓虹色。"
            )
        ),
        StyleSkillProfile(
            id: ArtStyle.japaneseAesthetic.rawValue,
            definition: SkillDefinition(
                id: ArtStyle.japaneseAesthetic.rawValue,
                displayName: "日系美学",
                description: "日系美学，柔焦背景，细腻柔和的氛围",
                category: .styleProfile,
                capabilities: [.stylePrompting]
            ),
            payload: StyleSkillPayload(
                legacyArtStyle: .japaneseAesthetic,
                icon: "leaf.fill",
                poemStyleGuide: "诗歌语言如日系俳句：极致凝练，捕捉一瞬间的感触，带有物哀之美，语调克制含蓄，留白多于倾诉。",
                imagePromptGuide: "画面强调留白、柔焦、季节感和克制色彩，突出一瞬间的细微情绪与安静氛围。",
                agentInterpretationGuide: "解读语气克制、温柔、留白感强。优先点出一两个核心意象，不要堆叠过多结论。",
                negativePromptGuide: "避免过度戏剧化、重口味奇观、强对比广告光效。"
            )
        ),
        StyleSkillProfile(
            id: ArtStyle.surreal.rawValue,
            definition: SkillDefinition(
                id: ArtStyle.surreal.rawValue,
                displayName: "超现实",
                description: "超现实主义，梦幻奇异，打破现实边界",
                category: .styleProfile,
                capabilities: [.stylePrompting]
            ),
            payload: StyleSkillPayload(
                legacyArtStyle: .surreal,
                icon: "star.circle.fill",
                poemStyleGuide: "诗歌语言如超现实画作：大胆拼接不相关的意象，跳跃、荒诞、出其不意，像梦中逻辑一样自然流畅。",
                imagePromptGuide: "画面允许非现实透视、漂浮、变形、意象错置，但仍要围绕用户梦境原始实体，不可凭空发散成无关奇观。",
                agentInterpretationGuide: "解读可以更大胆地连接象征与潜意识，但必须落回用户的梦境内容与当下处境。",
                negativePromptGuide: "避免廉价恐怖、无关的怪诞拼贴、过多无意义物件。"
            )
        ),
        StyleSkillProfile(
            id: ArtStyle.romantic.rawValue,
            definition: SkillDefinition(
                id: ArtStyle.romantic.rawValue,
                displayName: "浪漫主义",
                description: "浪漫主义，情感丰富，戏剧性光影",
                category: .styleProfile,
                capabilities: [.stylePrompting]
            ),
            payload: StyleSkillPayload(
                legacyArtStyle: .romantic,
                icon: "heart.circle.fill",
                poemStyleGuide: "诗歌语言如浪漫主义：情感浓烈外放，用自然景观映射内心，修辞华丽，有戏剧性的张力和崇高感。",
                imagePromptGuide: "画面强调情感张力、戏剧光影、风云和自然之力，把梦中情绪放大为具象场面。",
                agentInterpretationGuide: "解读语气可以更有情感势能，但不要煽情过度；要把宏大情绪重新落回可执行建议。",
                negativePromptGuide: "避免过度甜腻、滤镜感偶像海报、廉价 fantasy 封面风。"
            )
        ),
        StyleSkillProfile(
            id: ArtStyle.minimalist.rawValue,
            definition: SkillDefinition(
                id: ArtStyle.minimalist.rawValue,
                displayName: "极简主义",
                description: "极简主义，简洁构图，留白艺术",
                category: .styleProfile,
                capabilities: [.stylePrompting]
            ),
            payload: StyleSkillPayload(
                legacyArtStyle: .minimalist,
                icon: "circle.grid.2x2",
                poemStyleGuide: "诗歌语言如极简主义：字数极少，每个字都不可删减，大量留白，一句话承载整首诗的重量。",
                imagePromptGuide: "画面强调极简构图、负空间、有限色彩和核心主体，不堆叠多余细节。",
                agentInterpretationGuide: "解读要短、准、克制。优先输出最有价值的两三点，不展开冗长铺陈。",
                negativePromptGuide: "避免细节过密、背景杂乱、叙事元素过多。"
            )
        ),
        StyleSkillProfile(
            id: ArtStyle.inkWash.rawValue,
            definition: SkillDefinition(
                id: ArtStyle.inkWash.rawValue,
                displayName: "水墨",
                description: "中国水墨画，写意泼墨，气韵生动",
                category: .styleProfile,
                capabilities: [.stylePrompting]
            ),
            payload: StyleSkillPayload(
                legacyArtStyle: .inkWash,
                icon: "paintbrush.pointed.fill",
                poemStyleGuide: "诗歌语言如水墨画：古典中文意境，用山水、烟雨、松竹等传统意象，句式参照古诗词韵律，淡墨浓情，意在画外。",
                imagePromptGuide: "画面强调水墨留白、墨色层次、宣纸质感和写意气韵，可用少量设色，不要做成工笔插画。",
                agentInterpretationGuide: "解读语气偏古典、含蓄、沉静，可适度借用传统表达，但要保证现代用户易懂。",
                negativePromptGuide: "避免厚重油画质感、霓虹科幻、卡通扁平化。"
            )
        )
    ]

    private static let activeSkills: [AppSkill] = [
        PassiveStyleSkill(profile: styleProfiles[0]),
        PassiveStyleSkill(profile: styleProfiles[1]),
        PassiveStyleSkill(profile: styleProfiles[2]),
        PassiveStyleSkill(profile: styleProfiles[3]),
        PassiveStyleSkill(profile: styleProfiles[4]),
        PassiveStyleSkill(profile: styleProfiles[5]),
        DreamRetrievalSkill(),
        TarotRetrievalSkill(),
        DreamInterpretationSkill(),
        ActionGuidanceSkill()
    ]

    private static let runnableSkills: [AgentRunnableSkill] = [
        DreamRetrievalSkill(),
        TarotRetrievalSkill(),
        DreamInterpretationSkill(),
        ActionGuidanceSkill()
    ]

    static var builtInSkills: [StyleSkillProfile] {
        styleProfiles
    }

    static var registeredSkills: [AppSkill] {
        activeSkills
    }

    static var registeredRunnableSkills: [AgentRunnableSkill] {
        runnableSkills
    }

    static func definitions(for capability: SkillCapability) -> [SkillDefinition] {
        activeSkills
            .map(\.definition)
            .filter { $0.capabilities.contains(capability) }
    }

    static func styleSkill(for id: String) -> StyleSkillProfile {
        styleProfiles.first(where: { $0.id == id }) ?? styleProfiles[0]
    }

    static func styleSkill(for artStyle: ArtStyle) -> StyleSkillProfile {
        styleProfiles.first(where: { $0.legacyArtStyle == artStyle }) ?? styleProfiles[0]
    }

    static func skillDefinition(for id: String) -> SkillDefinition? {
        activeSkills.first(where: { $0.definition.id == id })?.definition
    }

    static func skills(for capability: SkillCapability) -> [AppSkill] {
        activeSkills.filter { $0.definition.capabilities.contains(capability) }
    }

    static func runnableSkills(for capability: SkillCapability) -> [AgentRunnableSkill] {
        runnableSkills.filter { $0.definition.capabilities.contains(capability) }
    }
}
