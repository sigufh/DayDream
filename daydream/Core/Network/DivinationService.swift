import Foundation

enum DivinationService {

    private static let client = DashScopeClient()

    // MARK: - Hexagram System (六爻)

    enum YaoType: String, Codable {
        case oldYang = "老阳"    // 重阳，会变为阴
        case youngYang = "少阳"  // 阳，不变
        case oldYin = "老阴"     // 重阴，会变为阳
        case youngYin = "少阴"   // 阴，不变

        var symbol: String {
            switch self {
            case .oldYang: return "▬▬▬▬▬ ○"  // 阳动
            case .youngYang: return "▬▬▬▬▬"
            case .oldYin: return "▬▬ ▬▬ ×"   // 阴动
            case .youngYin: return "▬▬ ▬▬"
            }
        }

        var isYang: Bool {
            self == .oldYang || self == .youngYang
        }

        var isMoving: Bool {
            self == .oldYang || self == .oldYin
        }

        var transformed: YaoType {
            switch self {
            case .oldYang: return .youngYin
            case .oldYin: return .youngYang
            default: return self
            }
        }

        // 使用三枚硬币方法
        static func throwCoins() -> YaoType {
            let coins = (0..<3).map { _ in Bool.random() }  // true=正面(阳), false=反面(阴)
            let yangCount = coins.filter { $0 }.count

            switch yangCount {
            case 3: return .oldYang   // 三阳，老阳（9）
            case 2: return .youngYang // 二阳一阴，少阳（7）
            case 1: return .youngYin  // 二阴一阳，少阴（8）
            case 0: return .oldYin    // 三阴，老阴（6）
            default: return .youngYang
            }
        }
    }

    struct Hexagram {
        let yaos: [YaoType]  // 从下到上六爻
        let name: String
        let meaning: String
        let interpretation: String

        var code: String {
            yaos.map { $0.isYang ? "1" : "0" }.joined()
        }

        var display: String {
            yaos.reversed().map { $0.symbol }.joined(separator: "\n")
        }

        var movingYaos: [Int] {
            yaos.enumerated().compactMap { $0.element.isMoving ? $0.offset : nil }
        }

        var transformedHexagram: Hexagram? {
            guard !movingYaos.isEmpty else { return nil }
            let transformedYaos = yaos.map { $0.transformed }
            return lookupHexagram(yaos: transformedYaos)
        }
    }

    static func generateHexagram() -> [YaoType] {
        (0..<6).map { _ in YaoType.throwCoins() }
    }

    static func lookupHexagram(yaos: [YaoType]) -> Hexagram {
        let code = yaos.map { $0.isYang ? "1" : "0" }.joined()

        // 64卦完整版
        let hexagrams: [String: (name: String, meaning: String, interpretation: String)] = [
            // 上乾卦
            "111111": ("乾", "天", "元亨利贞。刚健中正，自强不息。龙德而正中，君子终日乾乾。"),
            "111110": ("夬", "泽天夬", "扬于王庭。决断之时，刚决柔也。君子以施禄及下，居德则忌。"),
            "111101": ("大有", "火天大有", "元亨。火在天上，大有。君子以遏恶扬善，顺天休命。"),
            "111100": ("大壮", "雷天大壮", "利贞。大者壮也，刚以动，正大而天地之情可见矣。"),
            "111011": ("小畜", "风天小畜", "亨。密云不雨，尚往也。君子以懿文德。"),
            "111010": ("需", "水天需", "有孚，光亨，贞吉。需，须也。险在前也，刚健而不陷。"),
            "111001": ("大畜", "山天大畜", "利贞。刚上而尚贤，能止健。君子以多识前言往行。"),
            "111000": ("泰", "地天泰", "小往大来，吉亨。天地交而万物通，上下交而其志同。"),

            // 上兑卦
            "011111": ("履", "天泽履", "履虎尾，不咥人，亨。刚中正，履帝位而不疚。"),
            "011110": ("兑", "泽", "亨，利贞。说以先民，民忘其劳。君子以朋友讲习。"),
            "011101": ("革", "泽火革", "己日乃孚，元亨利贞，悔亡。天地革而四时成。"),
            "011100": ("随", "泽雷随", "元亨利贞，无咎。天下随时，随时之义大矣哉。"),
            "011011": ("中孚", "风泽中孚", "豚鱼吉，利涉大川，利贞。中孚，柔在内而刚得中。"),
            "011010": ("节", "水泽节", "亨。苦节不可贞。节以制度，不伤财，不害民。"),
            "011001": ("损", "山泽损", "有孚，元吉，无咎，可贞。损下益上，其道上行。"),
            "011000": ("临", "地泽临", "元亨利贞。至于八月有凶。刚浸而长，说而顺。"),

            // 上离卦
            "101111": ("同人", "天火同人", "同人于野，亨。利涉大川，利君子贞。"),
            "101110": ("睽", "火泽睽", "小事吉。天地睽而其事同，男女睽而其志通。"),
            "101101": ("离", "火", "利贞，亨。畜牝牛，吉。重明以丽乎正，乃化成天下。"),
            "101100": ("丰", "雷火丰", "亨，王假之。宜日中。丰大也，明以动，故丰。"),
            "101011": ("家人", "风火家人", "利女贞。家人，女正位乎内，男正位乎外。"),
            "101010": ("既济", "水火既济", "亨小，利贞。初吉终乱。水在火上，既济。"),
            "101001": ("贲", "山火贲", "亨。小利有攸往。刚柔交错，天文也。"),
            "101000": ("明夷", "地火明夷", "利艰贞。内文明而外柔顺，以蒙大难。"),

            // 上震卦
            "001111": ("无妄", "天雷无妄", "元亨利贞。其匪正有眚，不利有攸往。"),
            "001110": ("归妹", "雷泽归妹", "征凶，无攸利。天地之大义也。"),
            "001101": ("噬嗑", "火雷噬嗑", "亨，利用狱。颐中有物曰噬嗑。"),
            "001100": ("震", "雷", "亨。震来虩虩，笑言哑哑。震惊百里，不丧匕鬯。"),
            "001011": ("益", "风雷益", "利有攸往，利涉大川。损上益下，民说无疆。"),
            "001010": ("屯", "水雷屯", "元亨利贞。勿用有攸往，利建侯。刚柔始交而难生。"),
            "001001": ("颐", "山雷颐", "贞吉。观颐，自求口实。君子以慎言语，节饮食。"),
            "001000": ("复", "地雷复", "亨。出入无疾，朋来无咎。反复其道，七日来复。"),

            // 上巽卦
            "110111": ("小过", "雷山小过", "亨，利贞。可小事，不可大事。飞鸟遗之音。"),
            "110110": ("困", "泽山困", "亨，贞，大人吉，无咎。有言不信。君子以致命遂志。"),
            "110101": ("旅", "火山旅", "小亨，旅贞吉。山上有火，旅。君子以明慎用刑。"),
            "110100": ("渐", "风山渐", "女归吉，利贞。山上有木，渐。君子以居贤德善俗。"),
            "110011": ("巽", "风", "小亨，利有攸往，利见大人。随风，巽。君子以申命行事。"),
            "110010": ("涣", "风水涣", "亨，利涉大川，利贞。风行水上，涣。先王以享于帝立庙。"),
            "110001": ("蛊", "山风蛊", "元亨，利涉大川。先甲三日，后甲三日。"),
            "110000": ("升", "地风升", "元亨，用见大人，勿恤，南征吉。地中生木，升。"),

            // 上坎卦
            "010111": ("讼", "天水讼", "有孚窒惕，中吉，终凶。利见大人，不利涉大川。"),
            "010110": ("困", "泽水困", "亨，贞，大人吉，无咎。有言不信。泽无水，困。"),
            "010101": ("未济", "火水未济", "亨。小狐汔济，濡其尾，无攸利。"),
            "010100": ("解", "雷水解", "利西南，无所往，其来复吉。有攸往，夙吉。"),
            "010011": ("井", "风水井", "改邑不改井，无丧无得。往来井井。木上有水，井。"),
            "010010": ("坎", "水", "习坎，有孚，维心亨，行有尚。水洊至，习坎。"),
            "010001": ("蒙", "山水蒙", "亨。匪我求童蒙，童蒙求我。山下出泉，蒙。"),
            "010000": ("师", "地水师", "贞，丈人吉，无咎。地中有水，师。君子以容民畜众。"),

            // 上艮卦
            "100111": ("遁", "天山遁", "亨，小利贞。天下有山，遁。君子以远小人，不恶而严。"),
            "100110": ("咸", "泽山咸", "亨，利贞。取女吉。山上有泽，咸。君子以虚受人。"),
            "100101": ("旅", "火山旅", "小亨，旅贞吉。山上有火，旅。君子以明慎用刑。"),
            "100100": ("小过", "雷山小过", "亨，利贞。可小事，不可大事。飞鸟遗之音。"),
            "100011": ("渐", "风山渐", "女归吉，利贞。山上有木，渐。君子以居贤德善俗。"),
            "100010": ("蹇", "水山蹇", "利西南，不利东北。利见大人，贞吉。"),
            "100001": ("艮", "山", "艮其背，不获其身。行其庭，不见其人，无咎。"),
            "100000": ("谦", "地山谦", "亨，君子有终。天道下济而光明，地道卑而上行。"),

            // 上坤卦
            "000111": ("否", "天地否", "否之匪人，不利君子贞，大往小来。"),
            "000110": ("萃", "泽地萃", "亨，王假有庙。利见大人，亨，利贞。"),
            "000101": ("晋", "火地晋", "康侯用锡马蕃庶，昼日三接。明出地上，晋。"),
            "000100": ("豫", "雷地豫", "利建侯行师。雷出地奋，豫。先王以作乐崇德。"),
            "000011": ("观", "风地观", "盥而不荐，有孚颙若。风行地上，观。"),
            "000010": ("比", "水地比", "吉。原筮，元永贞，无咎。地上有水，比。"),
            "000001": ("剥", "山地剥", "不利有攸往。山附于地，剥。上以厚下安宅。"),
            "000000": ("坤", "地", "元亨，利牝马之贞。地势坤，君子以厚德载物。"),
        ]

        if let info = hexagrams[code] {
            return Hexagram(yaos: yaos, name: info.name, meaning: info.meaning, interpretation: info.interpretation)
        }

        // 默认解释
        return Hexagram(
            yaos: yaos,
            name: "未名之卦",
            meaning: "变化莫测",
            interpretation: "此卦玄妙，需细心体悟。天道无常，随缘而动，顺势而为。"
        )
    }

    // MARK: - Leaf Types (保留用于视觉效果)

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

    static func zhouGongInterpret(dream: Dream) async -> String {
        if APIConfig.hasValidAPIKey {
            do {
                let systemPrompt = """
                你是周公，中国古代著名的解梦大师。严格按照《周公解梦》的传统体系和方法为用户解梦。

                解梦原则：
                - 必须使用周公解梦的传统意象解释（如：龙主贵、蛇主财、水主财运等）
                - 采用古典文言文或半文言风格，如"梦见XX，主XX"的句式
                - 引用或化用《周公解梦》中的经典解释
                - 包含吉凶预兆、运势走向、宜忌建议
                - 语气要庄重典雅，如同古代先贤批注梦书

                格式要求：
                第一段：点明主要意象及其吉凶（"梦XX，主XX"）
                第二段：详细分析梦境寓意和运势预测
                第三段：给出具体的宜忌建议

                直接给出解梦内容，不要加"周公曰"等前缀。200字以内。
                """

                let userMessage = """
                梦境内容：\(dream.transcript)
                梦中意象：\(dream.symbols.joined(separator: "、"))
                情绪基调：\(dream.emotion.displayName)
                """

                return try await client.chat(
                    system: systemPrompt,
                    userMessage: userMessage,
                    maxTokens: 512
                )
            } catch {
                print("Zhou Gong API failed, falling back to template: \(error)")
            }
        }

        return zhouGongFallback(dream: dream)
    }

    private static func zhouGongFallback(dream: Dream) -> String {
        var interpretations: [String] = []

        // 收集所有匹配的意象解释
        for symbol in dream.symbols {
            if let interp = symbolInterpretations[symbol] {
                interpretations.append(interp)
            }
        }

        // 如果有匹配的意象，用周公解梦格式返回
        if !interpretations.isEmpty {
            let mainSymbol = dream.symbols.first ?? "梦象"
            var result = "梦见\(mainSymbol)，"

            // 判断吉凶
            let positiveKeywords = ["吉", "亨通", "光明", "喜", "财", "贵"]
            let hasPositive = interpretations.joined().contains(where: { char in
                positiveKeywords.contains(String(char))
            })

            result += hasPositive ? "主吉。" : "宜慎。"
            result += "\n\n"
            result += interpretations.joined(separator: "\n\n")

            // 添加宜忌建议
            if hasPositive {
                result += "\n\n宜：把握时机，积极进取。忌：骄躁冒进。"
            } else {
                result += "\n\n宜：谨慎行事，守而待时。忌：贸然妄动。"
            }

            return result
        }

        // 如果没有匹配的意象，使用情绪解读
        if let emotionInterp = emotionInterpretations[dream.emotionRaw] {
            return emotionInterp
        }

        return "此梦意象深远，非常人所能尽解。宜静心观照，待时日自明。"
    }

    // MARK: - Hexagram Interpretation

    static func interpretHexagram(hexagram: Hexagram, dreams: [Dream]) async -> String {
        let transformedHex = hexagram.transformedHexagram
        let movingYaos = hexagram.movingYaos

        if APIConfig.hasValidAPIKey {
            do {
                let recentDream = dreams.first

                let systemPrompt = """
                你是一位精通易经的占卜大师，通晓六爻之法。
                用户通过六爻占卜得到了卦象，请根据本卦、变卦（如有）、动爻位置和用户最近的梦境给出解读。

                解卦原则：
                - 无动爻：以本卦卦辞断
                - 一个动爻：以本卦动爻爻辞断
                - 两个动爻：以本卦两动爻爻辞断，以上爻为主
                - 三个动爻：以本卦卦辞和变卦卦辞断，以本卦为主
                - 四个动爻：以变卦两不动爻爻辞断，以下爻为主
                - 五个动爻：以变卦不动爻爻辞断
                - 六个动爻：特殊情况，乾坤卦用用九用六，其他以变卦卦辞断

                语言风格要古朴典雅，如同古代先贤解卦。
                解读包含：卦象分析、变化趋势、时运预测、行事建议。
                直接给出解读内容，不要加任何前缀或格式标记。250字以内。
                """

                var userMessage = """
                本卦：【\(hexagram.name)】卦（\(hexagram.meaning)）
                卦辞：\(hexagram.interpretation)
                """

                if !movingYaos.isEmpty {
                    let yaoNames = ["初", "二", "三", "四", "五", "上"]
                    let movingYaoNames = movingYaos.map { yaoNames[$0] }.joined(separator: "、")
                    userMessage += "\n动爻：\(movingYaoNames)爻"

                    if let transformed = transformedHex {
                        userMessage += "\n变卦：【\(transformed.name)】卦（\(transformed.meaning)）"
                        userMessage += "\n变卦卦辞：\(transformed.interpretation)"
                    }
                }

                if let dream = recentDream {
                    userMessage += "\n\n最近梦境：\(dream.transcript)"
                    userMessage += "\n梦境情绪：\(dream.emotion.displayName)"
                }

                return try await client.chat(
                    system: systemPrompt,
                    userMessage: userMessage,
                    maxTokens: 600
                )
            } catch {
                print("Hexagram API failed, falling back to template: \(error)")
            }
        }

        return interpretHexagramFallback(hexagram: hexagram, dreams: dreams)
    }

    private static func interpretHexagramFallback(hexagram: Hexagram, dreams: [Dream]) -> String {
        let recentEmotion: String
        if let latest = dreams.first {
            recentEmotion = latest.emotion.displayName
        } else {
            recentEmotion = "平静"
        }

        let opening = "六爻既定，天机已现。"
        let movingYaos = hexagram.movingYaos
        let transformed = hexagram.transformedHexagram

        var result = """
        \(opening)

        本卦得【\(hexagram.name)】，象曰：\(hexagram.meaning)。
        \(hexagram.interpretation)
        """

        if !movingYaos.isEmpty, let transformed = transformed {
            let yaoNames = ["初", "二", "三", "四", "五", "上"]
            let movingYaoNames = movingYaos.map { yaoNames[$0] }.joined(separator: "、")

            result += """


            动爻在\(movingYaoNames)，变而成【\(transformed.name)】卦。
            """

            switch movingYaos.count {
            case 1:
                result += "一爻独动，专以此爻断之。"
            case 2:
                result += "两爻齐动，当以上爻为主断。"
            case 3:
                result += "三爻皆动，本卦主，变卦辅。"
            case 4:
                result += "四爻俱动，当观变卦不动之爻。"
            case 5:
                result += "五爻翻腾，变卦独静爻定吉凶。"
            case 6:
                result += "六爻皆变，乾坤之道，变化无穷。"
            default:
                break
            }
        } else {
            result += "\n\n六爻安静，卦象稳定，当以卦辞为主断。"
        }

        result += "\n\n观汝近日梦境，心怀\(recentEmotion)。顺应天时，守正待机，自有转圜。"

        return result
    }

    // MARK: - Leaf Divination (旧版，保留兼容)

    static func interpret(leaves: [LeafType], dreams: [Dream]) async -> String {
        if APIConfig.hasValidAPIKey {
            do {
                let leafMeanings = leaves.map { "\($0.name)（\($0.meaning)）" }.joined(separator: "、")
                let recentDream = dreams.first

                let systemPrompt = """
                你是一位神秘的占卜师，擅长通过落叶占卜来解读命运。
                用户摇动手机后落下了几片叶子，请根据叶子的种类和含义，结合用户最近的梦境，给出占卜解读。
                语言风格要神秘而温暖，像一位智慧的长者在指引方向。
                直接给出解读内容，不要加任何前缀或格式标记。150字以内。
                """

                var userMessage = "落叶：\(leafMeanings)"
                if let dream = recentDream {
                    userMessage += "\n最近的梦境：\(dream.transcript)"
                    userMessage += "\n梦境情绪：\(dream.emotion.displayName)"
                }

                return try await client.chat(
                    system: systemPrompt,
                    userMessage: userMessage,
                    maxTokens: 512
                )
            } catch {
                print("Leaf divination API failed, falling back to template: \(error)")
            }
        }

        return interpretFallback(leaves: leaves, dreams: dreams)
    }

    private static func interpretFallback(leaves: [LeafType], dreams: [Dream]) -> String {
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
