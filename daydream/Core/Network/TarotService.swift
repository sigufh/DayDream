import Foundation

enum TarotService {

    private static let client = DashScopeClient()

    // MARK: - Tarot Card

    struct TarotCard: Codable {
        let name: String
        let nameChinese: String
        let suit: String  // Major Arcana, Wands, Cups, Swords, Pentacles
        let meaning: String
        let reversedMeaning: String
        let keywords: [String]
        let imageSymbol: String  // SF Symbol name

        var displayName: String {
            "\(nameChinese) (\(name))"
        }
    }

    // MARK: - Major Arcana (大阿尔卡纳)

    static let majorArcana: [TarotCard] = [
        TarotCard(name: "The Fool", nameChinese: "愚者", suit: "Major Arcana", meaning: "新的开始，纯真，自发性", reversedMeaning: "鲁莽，冒险，愚蠢", keywords: ["开始", "冒险", "自由"], imageSymbol: "figure.walk"),
        TarotCard(name: "The Magician", nameChinese: "魔术师", suit: "Major Arcana", meaning: "显现，资源，力量", reversedMeaning: "操纵，缺乏能量", keywords: ["创造", "技能", "意志"], imageSymbol: "wand.and.stars"),
        TarotCard(name: "The High Priestess", nameChinese: "女祭司", suit: "Major Arcana", meaning: "直觉，神圣知识，潜意识", reversedMeaning: "秘密，脱离直觉", keywords: ["智慧", "神秘", "直觉"], imageSymbol: "moon.stars"),
        TarotCard(name: "The Empress", nameChinese: "皇后", suit: "Major Arcana", meaning: "丰饶，女性力量，自然", reversedMeaning: "依赖，缺乏成长", keywords: ["丰盛", "母性", "创造"], imageSymbol: "leaf.circle"),
        TarotCard(name: "The Emperor", nameChinese: "皇帝", suit: "Major Arcana", meaning: "权威，建立，结构", reversedMeaning: "专制，控制", keywords: ["权威", "秩序", "父性"], imageSymbol: "crown"),
        TarotCard(name: "The Hierophant", nameChinese: "教皇", suit: "Major Arcana", meaning: "传统，精神指导，教育", reversedMeaning: "反叛，颠覆", keywords: ["传统", "教导", "信仰"], imageSymbol: "book.closed"),
        TarotCard(name: "The Lovers", nameChinese: "恋人", suit: "Major Arcana", meaning: "爱，和谐，关系", reversedMeaning: "失衡，错位", keywords: ["爱情", "选择", "结合"], imageSymbol: "heart.circle"),
        TarotCard(name: "The Chariot", nameChinese: "战车", suit: "Major Arcana", meaning: "控制，意志力，胜利", reversedMeaning: "缺乏方向", keywords: ["胜利", "意志", "前进"], imageSymbol: "car"),
        TarotCard(name: "Strength", nameChinese: "力量", suit: "Major Arcana", meaning: "勇气，内在力量，耐心", reversedMeaning: "软弱，自我怀疑", keywords: ["勇气", "坚韧", "慈悲"], imageSymbol: "pawprint.circle"),
        TarotCard(name: "The Hermit", nameChinese: "隐士", suit: "Major Arcana", meaning: "自省，寻找真理，内在指引", reversedMeaning: "孤立，孤独", keywords: ["沉思", "智慧", "独处"], imageSymbol: "figure.stand"),
        TarotCard(name: "Wheel of Fortune", nameChinese: "命运之轮", suit: "Major Arcana", meaning: "好运，循环，命运", reversedMeaning: "厄运，抗拒改变", keywords: ["变化", "循环", "命运"], imageSymbol: "circle.hexagongrid"),
        TarotCard(name: "Justice", nameChinese: "正义", suit: "Major Arcana", meaning: "公正，真相，法律", reversedMeaning: "不公，欺骗", keywords: ["公平", "真理", "因果"], imageSymbol: "scale.3d"),
        TarotCard(name: "The Hanged Man", nameChinese: "倒吊人", suit: "Major Arcana", meaning: "暂停，放手，牺牲", reversedMeaning: "拖延，抗拒", keywords: ["牺牲", "顿悟", "换位"], imageSymbol: "figure.flexibility"),
        TarotCard(name: "Death", nameChinese: "死神", suit: "Major Arcana", meaning: "结束，转变，过渡", reversedMeaning: "抗拒改变", keywords: ["转变", "结束", "重生"], imageSymbol: "leaf.arrow.circlepath"),
        TarotCard(name: "Temperance", nameChinese: "节制", suit: "Major Arcana", meaning: "平衡，中庸，耐心", reversedMeaning: "失衡，过度", keywords: ["平衡", "和谐", "节制"], imageSymbol: "scale"),
        TarotCard(name: "The Devil", nameChinese: "恶魔", suit: "Major Arcana", meaning: "束缚，成瘾，物质主义", reversedMeaning: "释放，解脱", keywords: ["诱惑", "束缚", "欲望"], imageSymbol: "flame"),
        TarotCard(name: "The Tower", nameChinese: "高塔", suit: "Major Arcana", meaning: "突然改变，动荡，觉醒", reversedMeaning: "避免灾难", keywords: ["突变", "毁灭", "启示"], imageSymbol: "bolt.trianglebadge.exclamationmark"),
        TarotCard(name: "The Star", nameChinese: "星星", suit: "Major Arcana", meaning: "希望，信仰，重生", reversedMeaning: "绝望，缺乏信念", keywords: ["希望", "灵感", "宁静"], imageSymbol: "star"),
        TarotCard(name: "The Moon", nameChinese: "月亮", suit: "Major Arcana", meaning: "幻觉，恐惧，焦虑", reversedMeaning: "释放恐惧", keywords: ["幻象", "潜意识", "直觉"], imageSymbol: "moon"),
        TarotCard(name: "The Sun", nameChinese: "太阳", suit: "Major Arcana", meaning: "快乐，成功，庆祝", reversedMeaning: "过度乐观", keywords: ["成功", "喜悦", "活力"], imageSymbol: "sun.max"),
        TarotCard(name: "Judgement", nameChinese: "审判", suit: "Major Arcana", meaning: "判断，重生，内在呼唤", reversedMeaning: "自我怀疑", keywords: ["觉醒", "更新", "呼唤"], imageSymbol: "bell"),
        TarotCard(name: "The World", nameChinese: "世界", suit: "Major Arcana", meaning: "完成，成就，旅程结束", reversedMeaning: "未完成", keywords: ["完成", "成就", "整合"], imageSymbol: "globe"),
    ]

    // MARK: - Minor Arcana - Wands (权杖牌组)

    static let wands: [TarotCard] = [
        TarotCard(name: "Ace of Wands", nameChinese: "权杖王牌", suit: "Wands", meaning: "灵感，新机遇，成长", reversedMeaning: "缺乏方向，延迟", keywords: ["创意", "热情", "开始"], imageSymbol: "wand.and.rays"),
        TarotCard(name: "Two of Wands", nameChinese: "权杖二", suit: "Wands", meaning: "规划，决定，进展", reversedMeaning: "犹豫不决，恐惧", keywords: ["未来", "发现", "选择"], imageSymbol: "2.square"),
        TarotCard(name: "Three of Wands", nameChinese: "权杖三", suit: "Wands", meaning: "扩展，远见，领导力", reversedMeaning: "缺乏远见，延迟", keywords: ["探索", "企业", "贸易"], imageSymbol: "3.square"),
        TarotCard(name: "Four of Wands", nameChinese: "权杖四", suit: "Wands", meaning: "庆祝，和谐，回家", reversedMeaning: "不稳定，缺乏支持", keywords: ["聚会", "婚礼", "家园"], imageSymbol: "4.square"),
        TarotCard(name: "Five of Wands", nameChinese: "权杖五", suit: "Wands", meaning: "竞争，冲突，紧张", reversedMeaning: "避免冲突，和解", keywords: ["争执", "竞争", "意见不合"], imageSymbol: "5.square"),
        TarotCard(name: "Six of Wands", nameChinese: "权杖六", suit: "Wands", meaning: "胜利，认可，成功", reversedMeaning: "自负，失败", keywords: ["公众认可", "进步", "自信"], imageSymbol: "6.square"),
        TarotCard(name: "Seven of Wands", nameChinese: "权杖七", suit: "Wands", meaning: "挑战，坚持，毅力", reversedMeaning: "疲惫，放弃", keywords: ["防御", "保护立场", "坚持"], imageSymbol: "7.square"),
        TarotCard(name: "Eight of Wands", nameChinese: "权杖八", suit: "Wands", meaning: "快速行动，进展，变化", reversedMeaning: "延迟，挫折", keywords: ["速度", "旅行", "运动"], imageSymbol: "8.square"),
        TarotCard(name: "Nine of Wands", nameChinese: "权杖九", suit: "Wands", meaning: "韧性，坚持，考验", reversedMeaning: "偏执，顽固", keywords: ["勇气", "坚持", "界限"], imageSymbol: "9.square"),
        TarotCard(name: "Ten of Wands", nameChinese: "权杖十", suit: "Wands", meaning: "负担，责任，压力", reversedMeaning: "释放负担，委派", keywords: ["重担", "辛劳", "承担"], imageSymbol: "10.square"),
        TarotCard(name: "Page of Wands", nameChinese: "权杖侍从", suit: "Wands", meaning: "灵感，发现，自由精神", reversedMeaning: "缺乏方向，拖延", keywords: ["探索", "兴奋", "自由"], imageSymbol: "figure.walk.circle"),
        TarotCard(name: "Knight of Wands", nameChinese: "权杖骑士", suit: "Wands", meaning: "能量，冲动，冒险", reversedMeaning: "鲁莽，缺乏耐心", keywords: ["行动", "冲动", "冒险"], imageSymbol: "figure.run"),
        TarotCard(name: "Queen of Wands", nameChinese: "权杖王后", suit: "Wands", meaning: "自信，独立，活力", reversedMeaning: "嫉妒，不安全感", keywords: ["勇气", "魅力", "决心"], imageSymbol: "crown.fill"),
        TarotCard(name: "King of Wands", nameChinese: "权杖国王", suit: "Wands", meaning: "领导力，愿景，企业家", reversedMeaning: "专横，冲动", keywords: ["企业", "荣誉", "大胆"], imageSymbol: "crown"),
    ]

    // MARK: - Minor Arcana - Cups (圣杯牌组)

    static let cups: [TarotCard] = [
        TarotCard(name: "Ace of Cups", nameChinese: "圣杯王牌", suit: "Cups", meaning: "新的感情，直觉，灵性", reversedMeaning: "情感封闭，压抑", keywords: ["爱", "新关系", "慈悲"], imageSymbol: "cup.and.saucer"),
        TarotCard(name: "Two of Cups", nameChinese: "圣杯二", suit: "Cups", meaning: "统一，伙伴关系，连接", reversedMeaning: "失衡，紧张关系", keywords: ["伙伴", "爱情", "和谐"], imageSymbol: "heart.text.square"),
        TarotCard(name: "Three of Cups", nameChinese: "圣杯三", suit: "Cups", meaning: "庆祝，友谊，社区", reversedMeaning: "过度放纵，孤立", keywords: ["友谊", "社交", "创造"], imageSymbol: "person.3"),
        TarotCard(name: "Four of Cups", nameChinese: "圣杯四", suit: "Cups", meaning: "沉思，冷漠，重新评估", reversedMeaning: "撤退，幻灭", keywords: ["冥想", "内省", "机会"], imageSymbol: "figure.mind.and.body"),
        TarotCard(name: "Five of Cups", nameChinese: "圣杯五", suit: "Cups", meaning: "悲伤，遗憾，失望", reversedMeaning: "接受，前进", keywords: ["失落", "悲伤", "自怜"], imageSymbol: "drop.triangle"),
        TarotCard(name: "Six of Cups", nameChinese: "圣杯六", suit: "Cups", meaning: "怀旧，回忆，童心", reversedMeaning: "困于过去", keywords: ["童年", "记忆", "天真"], imageSymbol: "sparkles"),
        TarotCard(name: "Seven of Cups", nameChinese: "圣杯七", suit: "Cups", meaning: "幻想，选择，许愿", reversedMeaning: "一致性，决定", keywords: ["幻想", "想象", "幻觉"], imageSymbol: "cloud"),
        TarotCard(name: "Eight of Cups", nameChinese: "圣杯八", suit: "Cups", meaning: "离开，撤退，寻找真理", reversedMeaning: "害怕离开，停滞", keywords: ["离开", "撤退", "寻找"], imageSymbol: "figure.walk.departure"),
        TarotCard(name: "Nine of Cups", nameChinese: "圣杯九", suit: "Cups", meaning: "满足，愿望成真，幸福", reversedMeaning: "内心不满，贪婪", keywords: ["满足", "愿望", "成就"], imageSymbol: "star.fill"),
        TarotCard(name: "Ten of Cups", nameChinese: "圣杯十", suit: "Cups", meaning: "和谐，幸福，一致", reversedMeaning: "家庭纷争，破裂", keywords: ["家庭", "和谐", "幸福"], imageSymbol: "house"),
        TarotCard(name: "Page of Cups", nameChinese: "圣杯侍从", suit: "Cups", meaning: "创意信息，直觉，好奇", reversedMeaning: "情绪不成熟", keywords: ["想象", "直觉", "艺术"], imageSymbol: "envelope"),
        TarotCard(name: "Knight of Cups", nameChinese: "圣杯骑士", suit: "Cups", meaning: "浪漫，魅力，想象", reversedMeaning: "情绪化，不切实际", keywords: ["浪漫", "提议", "邀请"], imageSymbol: "heart.circle.fill"),
        TarotCard(name: "Queen of Cups", nameChinese: "圣杯王后", suit: "Cups", meaning: "慈悲，平静，直觉", reversedMeaning: "情绪不稳，依赖", keywords: ["同理心", "关怀", "感受"], imageSymbol: "heart.square.fill"),
        TarotCard(name: "King of Cups", nameChinese: "圣杯国王", suit: "Cups", meaning: "情感平衡，外交，慷慨", reversedMeaning: "情绪操纵，易变", keywords: ["同情", "平衡", "冷静"], imageSymbol: "figure.wave"),
    ]

    // MARK: - Minor Arcana - Swords (宝剑牌组)

    static let swords: [TarotCard] = [
        TarotCard(name: "Ace of Swords", nameChinese: "宝剑王牌", suit: "Swords", meaning: "突破，清晰，新想法", reversedMeaning: "混乱，残酷", keywords: ["真相", "正义", "清晰"], imageSymbol: "flashlight.on.fill"),
        TarotCard(name: "Two of Swords", nameChinese: "宝剑二", suit: "Swords", meaning: "困难的选择，僵局，回避", reversedMeaning: "信息过载，犹豫", keywords: ["选择", "平衡", "停滞"], imageSymbol: "arrow.left.arrow.right"),
        TarotCard(name: "Three of Swords", nameChinese: "宝剑三", suit: "Swords", meaning: "心碎，悲伤，痛苦", reversedMeaning: "恢复，原谅", keywords: ["心痛", "背叛", "分离"], imageSymbol: "heart.slash"),
        TarotCard(name: "Four of Swords", nameChinese: "宝剑四", suit: "Swords", meaning: "休息，恢复，沉思", reversedMeaning: "精疲力尽，倦怠", keywords: ["休息", "恢复", "冥想"], imageSymbol: "bed.double"),
        TarotCard(name: "Five of Swords", nameChinese: "宝剑五", suit: "Swords", meaning: "冲突，失败，紧张", reversedMeaning: "和解，原谅", keywords: ["冲突", "失败", "敌意"], imageSymbol: "exclamationmark.triangle"),
        TarotCard(name: "Six of Swords", nameChinese: "宝剑六", suit: "Swords", meaning: "过渡，改变，旅行", reversedMeaning: "抗拒改变，动荡", keywords: ["旅程", "过渡", "放手"], imageSymbol: "ferry"),
        TarotCard(name: "Seven of Swords", nameChinese: "宝剑七", suit: "Swords", meaning: "欺骗，策略，逃避", reversedMeaning: "坦白，真相揭露", keywords: ["背叛", "狡猾", "策略"], imageSymbol: "eye.slash"),
        TarotCard(name: "Eight of Swords", nameChinese: "宝剑八", suit: "Swords", meaning: "限制，困境，无助", reversedMeaning: "释放，自由", keywords: ["限制", "困境", "受害者"], imageSymbol: "lock"),
        TarotCard(name: "Nine of Swords", nameChinese: "宝剑九", suit: "Swords", meaning: "焦虑，噩梦，绝望", reversedMeaning: "希望，恢复", keywords: ["恐惧", "噩梦", "焦虑"], imageSymbol: "moon.zzz"),
        TarotCard(name: "Ten of Swords", nameChinese: "宝剑十", suit: "Swords", meaning: "结束，失败，崩溃", reversedMeaning: "恢复，再生", keywords: ["背叛", "结束", "痛苦"], imageSymbol: "xmark.circle"),
        TarotCard(name: "Page of Swords", nameChinese: "宝剑侍从", suit: "Swords", meaning: "好奇，敏锐，不安", reversedMeaning: "闲话，轻率", keywords: ["好奇", "警觉", "防御"], imageSymbol: "eye"),
        TarotCard(name: "Knight of Swords", nameChinese: "宝剑骑士", suit: "Swords", meaning: "雄心，行动，坚定", reversedMeaning: "鲁莽，不顾后果", keywords: ["行动", "冲动", "防御"], imageSymbol: "bolt"),
        TarotCard(name: "Queen of Swords", nameChinese: "宝剑王后", suit: "Swords", meaning: "独立，公正，感知", reversedMeaning: "残酷，怨恨", keywords: ["正直", "独立", "原则"], imageSymbol: "sparkle"),
        TarotCard(name: "King of Swords", nameChinese: "宝剑国王", suit: "Swords", meaning: "权威，真理，理智", reversedMeaning: "操纵，专制", keywords: ["真相", "正义", "道德"], imageSymbol: "brain.head.profile"),
    ]

    // MARK: - Minor Arcana - Pentacles (星币牌组)

    static let pentacles: [TarotCard] = [
        TarotCard(name: "Ace of Pentacles", nameChinese: "星币王牌", suit: "Pentacles", meaning: "新的机会，繁荣，安全", reversedMeaning: "错失机会，稀缺", keywords: ["显现", "财富", "机会"], imageSymbol: "dollarsign.circle"),
        TarotCard(name: "Two of Pentacles", nameChinese: "星币二", suit: "Pentacles", meaning: "平衡，适应，时间管理", reversedMeaning: "失衡，混乱", keywords: ["平衡", "优先级", "适应"], imageSymbol: "arrow.trianglehead.2.clockwise"),
        TarotCard(name: "Three of Pentacles", nameChinese: "星币三", suit: "Pentacles", meaning: "合作，学习，实施", reversedMeaning: "缺乏团队合作", keywords: ["团队合作", "合作", "学习"], imageSymbol: "person.2"),
        TarotCard(name: "Four of Pentacles", nameChinese: "星币四", suit: "Pentacles", meaning: "保护，控制，安全", reversedMeaning: "贪婪，物质主义", keywords: ["控制", "稳定", "拥有"], imageSymbol: "shield"),
        TarotCard(name: "Five of Pentacles", nameChinese: "星币五", suit: "Pentacles", meaning: "经济困难，贫困，孤立", reversedMeaning: "恢复，改善", keywords: ["失落", "贫困", "不安"], imageSymbol: "snow"),
        TarotCard(name: "Six of Pentacles", nameChinese: "星币六", suit: "Pentacles", meaning: "慷慨，慈善，分享", reversedMeaning: "自私，债务", keywords: ["给予", "接受", "分享"], imageSymbol: "hand.raised"),
        TarotCard(name: "Seven of Pentacles", nameChinese: "星币七", suit: "Pentacles", meaning: "长期目标，耐心，投资", reversedMeaning: "缺乏远见，挫折", keywords: ["投资", "努力", "回报"], imageSymbol: "chart.line.uptrend.xyaxis"),
        TarotCard(name: "Eight of Pentacles", nameChinese: "星币八", suit: "Pentacles", meaning: "技艺，勤奋，技能", reversedMeaning: "敷衍，野心", keywords: ["学徒", "重复", "知识"], imageSymbol: "hammer"),
        TarotCard(name: "Nine of Pentacles", nameChinese: "星币九", suit: "Pentacles", meaning: "富足，优雅，自给自足", reversedMeaning: "过度工作，独立幻想", keywords: ["富裕", "生活方式", "独立"], imageSymbol: "leaf.fill"),
        TarotCard(name: "Ten of Pentacles", nameChinese: "星币十", suit: "Pentacles", meaning: "财富，遗产，家庭", reversedMeaning: "经济失败，债务", keywords: ["传承", "财富", "建立"], imageSymbol: "building.columns"),
        TarotCard(name: "Page of Pentacles", nameChinese: "星币侍从", suit: "Pentacles", meaning: "显现，经济机会，技能", reversedMeaning: "缺乏进展，拖延", keywords: ["学习", "机会", "目标"], imageSymbol: "studentdesk"),
        TarotCard(name: "Knight of Pentacles", nameChinese: "星币骑士", suit: "Pentacles", meaning: "效率，常规，保守", reversedMeaning: "懒惰，完美主义", keywords: ["勤奋", "常规", "保守"], imageSymbol: "tortoise"),
        TarotCard(name: "Queen of Pentacles", nameChinese: "星币王后", suit: "Pentacles", meaning: "实际，养育，提供", reversedMeaning: "金融不安全，窒息", keywords: ["养育", "实际", "提供"], imageSymbol: "house.and.flag"),
        TarotCard(name: "King of Pentacles", nameChinese: "星币国王", suit: "Pentacles", meaning: "富足，安全，领导", reversedMeaning: "贪婪，物质主义", keywords: ["富裕", "商业", "安全"], imageSymbol: "banknote"),
    ]

    // MARK: - All Cards

    static let allCards: [TarotCard] = majorArcana + wands + cups + swords + pentacles

    // MARK: - Card Drawing

    struct TarotReading: Codable {
        let cards: [DrawnCard]
        let spread: SpreadType
        let interpretation: String

        struct DrawnCard: Codable {
            let card: TarotCard
            let isReversed: Bool
            let position: String  // "Past", "Present", "Future" etc.
        }
    }

    enum SpreadType: String, Codable {
        case single = "单张"
        case threeCard = "三牌阵"
        case celtic = "凯尔特十字"

        var positions: [String] {
            switch self {
            case .single:
                return ["当前"]
            case .threeCard:
                return ["过去", "现在", "未来"]
            case .celtic:
                return ["现状", "挑战", "根源", "过去", "目标", "未来", "自己", "环境", "希望恐惧", "结果"]
            }
        }
    }

    static func drawCards(count: Int, deckType: DeckType = .full) -> [TarotReading.DrawnCard] {
        let deck: [TarotCard]
        switch deckType {
        case .majorOnly:
            deck = majorArcana
        case .full:
            deck = allCards
        }

        let shuffled = deck.shuffled()
        let positions = count == 1 ? ["当前"] : count == 3 ? ["过去", "现在", "未来"] : (1...count).map { "位置\($0)" }

        return shuffled.prefix(count).enumerated().map { index, card in
            TarotReading.DrawnCard(
                card: card,
                isReversed: Bool.random(),
                position: positions[index]
            )
        }
    }

    enum DeckType {
        case majorOnly  // 仅大阿尔卡纳22张
        case full       // 全部78张
    }

    // MARK: - Interpretation

    static func interpret(reading: TarotReading, dreams: [Dream]) async -> String {
        if APIConfig.hasValidAPIKey {
            do {
                let recentDream = dreams.first

                let systemPrompt = """
                You are a professional tarot reader with deep knowledge of Western mysticism and symbolism.
                The user has drawn tarot cards. Provide an insightful reading based on the cards, their positions, and upright/reversed orientations.
                Incorporate the user's recent dream if provided, connecting it to the tarot symbolism.

                Style guidelines:
                - Use mystical yet accessible language typical of tarot readings
                - Reference archetypal symbolism, spiritual guidance, and intuitive wisdom
                - Include practical advice grounded in the cards' meanings
                - Structure: card analysis → overall message → guidance for the querent

                Respond in Chinese, but use Western tarot reading conventions and terminology.
                Keep it under 250 characters. No formatting markers, just the reading.
                """

                var userMessage = "Spread: \(reading.spread.rawValue)\n\n"
                for drawnCard in reading.cards {
                    let orientation = drawnCard.isReversed ? "Reversed" : "Upright"
                    let meaning = drawnCard.isReversed ? drawnCard.card.reversedMeaning : drawnCard.card.meaning
                    userMessage += "[\(drawnCard.position)] \(drawnCard.card.name) (\(orientation)): \(meaning)\n"
                }

                if let dream = recentDream {
                    userMessage += "\nRecent dream: \(dream.transcript)"
                    userMessage += "\nDream emotion: \(dream.emotion.displayName)"
                }

                return try await client.chat(
                    system: systemPrompt,
                    userMessage: userMessage,
                    maxTokens: 600
                )
            } catch {
                print("Tarot API failed, falling back to template: \(error)")
            }
        }

        return interpretFallback(reading: reading)
    }

    private static func interpretFallback(reading: TarotReading) -> String {
        var result = "The cards have spoken.\n\n"

        for drawnCard in reading.cards {
            let orientation = drawnCard.isReversed ? "逆位" : "正位"
            let meaning = drawnCard.isReversed ? drawnCard.card.reversedMeaning : drawnCard.card.meaning
            result += "**\(drawnCard.position) - \(drawnCard.card.nameChinese)** (\(orientation))\n"
            result += "\(meaning)\n\n"
        }

        // 不同牌阵的通用指引
        let guidance: String
        switch reading.cards.count {
        case 1:
            guidance = "这张牌揭示了你当前的能量状态。倾听内在的声音，它将指引你前行的方向。"
        case 3:
            guidance = "过去的经历塑造了现在，而你的选择将创造未来。接纳这个过程，保持觉知。"
        default:
            guidance = "牌面展现了一个完整的故事。每张牌都是拼图的一部分，整合它们，你将看到全貌。"
        }

        result += guidance

        return result
    }
}
