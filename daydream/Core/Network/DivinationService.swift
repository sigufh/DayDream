import Foundation

enum DivinationService {

    // MARK: - Leaf Types

    struct LeafType {
        let name: String
        let meaning: String
        let colorHex: String
    }

    static let leafTypes: [LeafType] = [
        LeafType(name: "枫叶", meaning: "思念与离别", colorHex: "E57373"),
        LeafType(name: "银杏", meaning: "坚韧与长寿", colorHex: "FFD54F"),
        LeafType(name: "柳叶", meaning: "柔情与思念", colorHex: "AED581"),
        LeafType(name: "竹叶", meaning: "清高与正直", colorHex: "81C784"),
        LeafType(name: "荷叶", meaning: "纯洁与超脱", colorHex: "80CBC4"),
        LeafType(name: "松针", meaning: "长青与不屈", colorHex: "4DB6AC"),
        LeafType(name: "桃花", meaning: "姻缘与桃运", colorHex: "F48FB1"),
        LeafType(name: "梅花", meaning: "傲骨与坚贞", colorHex: "CE93D8"),
    ]

    static func randomLeaves(count: Int = 3) -> [LeafType] {
        Array(leafTypes.shuffled().prefix(count))
    }

    // MARK: - Zhou Gong Interpretation

    private static let symbolInterpretations: [String: String] = [
        "月亮": "月亮象征着内心的直觉与潜意识。梦见月亮，主内心通透，近期将有所顿悟。",
        "水": "水为财之象。清水主财运亨通，浑水则需谨防小人。",
        "光": "光明入梦，乃吉兆也。预示困境将解，前路渐明。",
        "飞翔": "梦中飞翔，主心志高远。近期事业或有突破之机。",
        "门": "门为出入之道。梦见门开，主机遇将至；门闭，则需耐心等待。",
        "钥匙": "钥匙主解惑。梦见钥匙，预示困扰已久的问题即将找到答案。",
        "花": "花开主喜事。梦见鲜花盛开，近期或有喜讯传来。",
        "雨": "雨润万物。梦见下雨，主烦恼消散，心境将有转变。",
        "镜子": "镜子照见真我。梦见镜子，主需审视自身，反思近日所行。",
        "星辰": "星辰主远大志向。梦见星光灿烂，预示目标渐近。",
        "路": "路主人生方向。梦见大路，主前途光明；小路，则需谨慎选择。",
        "桥": "桥为过渡之象。梦见桥梁，预示人生阶段将有转换。",
        "风": "风主变化。梦见和风，主顺遂；狂风，则有变数将至。",
        "树": "树主根基。梦见大树繁茂，主家业兴旺，根基稳固。",
        "鸟": "鸟主自由与消息。梦见飞鸟，近期或有远方消息传来。",
    ]

    private static let emotionInterpretations: [String: String] = [
        "serenity": "此梦平和安宁，主心境澄明。近日宜静养身心，修行内功。",
        "melancholy": "此梦带有淡愁，乃心中思念之象。不必忧虑，情感的流动正是内心的疗愈。",
        "anxiety": "此梦有焦躁之气，主近日压力未消。建议放慢脚步，给自己留出喘息的空间。",
        "hope": "此梦充满生机，大吉之兆。预示心愿可期，近期运势上升。",
        "whimsy": "此梦奇幻瑰丽，主想象力丰沛。创造力正旺，宜把握灵感之机。",
    ]

    static func zhouGongInterpret(dream: Dream) -> String {
        // Try symbol-based interpretation first
        var interpretations: [String] = []
        for symbol in dream.symbols {
            if let interp = symbolInterpretations[symbol] {
                interpretations.append(interp)
            }
        }

        if !interpretations.isEmpty {
            return interpretations.joined(separator: "\n\n")
        }

        // Fallback to emotion-based
        return emotionInterpretations[dream.emotionRaw] ?? "此梦意象深远，需细细品味方能悟其真意。"
    }

    // MARK: - Leaf Divination

    static func interpret(leaves: [LeafType], dreams: [Dream]) -> String {
        let leafMeanings = leaves.map { "\($0.name)（\($0.meaning)）" }.joined(separator: "、")

        let recentEmotion: String
        if let latest = dreams.first {
            recentEmotion = latest.emotion.displayName
        } else {
            recentEmotion = "平静"
        }

        let openings = [
            "三叶落定，天机已现。",
            "叶落知秋，命理自明。",
            "风送三叶，各有所指。",
        ]

        let closings = [
            "综合来看，近日宜\(leaves.count == 3 ? "顺其自然" : "静待时机")，心怀\(recentEmotion)之意，自有转机。",
            "三叶合一，暗示内心正在经历\(recentEmotion)的洗礼，这是成长的必经之路。",
            "此签寓意深远：接纳当下的\(recentEmotion)，便是最好的修行。",
        ]

        let opening = openings.randomElement()!
        let closing = closings.randomElement()!

        return "\(opening)\n\n所得\(leafMeanings)。\n\n\(closing)"
    }
}
