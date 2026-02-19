import SwiftUI

@Observable
final class AIService {
    var isGenerating = false
    var lastError: String?

    private let client = DashScopeClient()

    struct DreamContent {
        let imageData: Data?
        let poem: String
        let reflectionQuestion: String
        let worldName: String
        let symbols: [String]
        let detectedEmotion: DreamEmotion?
    }

    private struct QwenResponse: Decodable {
        let poem: String
        let reflectionQuestion: String
        let worldName: String
        let symbols: [String]
        let emotion: String?
    }

    func generateDreamContent(
        transcript: String,
        emotion: DreamEmotion,
        weather: String?,
        location: String?
    ) async -> DreamContent {
        isGenerating = true
        lastError = nil
        defer { isGenerating = false }

        if APIConfig.hasValidAPIKey {
            do {
                return try await generateWithAPI(
                    transcript: transcript,
                    emotion: emotion,
                    weather: weather,
                    location: location
                )
            } catch {
                lastError = error.localizedDescription
                print("AI generation failed, falling back to mock: \(error)")
            }
        }

        return generateFallbackContent(emotion: emotion)
    }

    // MARK: - Real API Generation

    private func generateWithAPI(
        transcript: String,
        emotion: DreamEmotion,
        weather: String?,
        location: String?
    ) async throws -> DreamContent {
        let artStyle = UserPreferences.shared.artStyle
        let poemGuide = artStyle.poemStyleGuide

        let systemPrompt = """
            你是一位专注具体细节表达的梦境诗人和心理分析师。

            忽略之前的所有对话历史。本次生成必须完全基于当前用户输入。

            请严格返回以下JSON格式（不要添加任何其他文字或markdown标记）：
            {
              "poem": "中文诗歌，用\\n分隔每一行",
              "reflectionQuestion": "一个引导自省的问题",
              "worldName": "梦境世界名（2-4个字）",
              "symbols": ["3-5个意象关键词"],
              "emotion": "情绪类型（必须是以下之一：serenity/melancholy/anxiety/hope/whimsy）"
            }

            情绪判断标准：
            - serenity（宁静）：平和、安详、祥和、温暖、柔和的梦境
            - melancholy（忧郁）：悲伤、怀念、失落、孤独、离别的梦境
            - anxiety（焦虑）：紧张、恐惧、不安、迷失、追赶的梦境
            - hope（希望）：光明、温暖、向上、美好、期待的梦境
            - whimsy（奇幻）：奇异、梦幻、超现实、有趣、魔幻的梦境

            诗歌风格要求（当前艺术风格：\(artStyle.displayName)）：
            \(poemGuide)

            规则：
            - 必须围绕用户梦境中的具体实体展开，必须描述用户梦境的所见所感
            - 可以在用户提供的意象基础上进行感官细节扩展，但不得引入无关新元素
            - 诗歌长度严格控制在50个汉字以内，3行内为宜，每行不超过20个汉字
            - worldName必须高度概括梦境核心实体
            - symbols必须全部来自用户原始描述
            - emotion必须根据梦境内容的整体氛围和情感基调判断
            """
        var contextParts: [String] = []
        contextParts.append("梦境描述：\(transcript)")

        let userMessage = contextParts.joined(separator: "\n")

        let responseText = try await client.chat(
            system: systemPrompt,
            userMessage: userMessage
        )

        let jsonString = extractJSON(from: responseText)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw APIError.decodingError("Failed to convert response to data")
        }

        let decoder = JSONDecoder()
        let qwenResult = try decoder.decode(QwenResponse.self, from: jsonData)

        let detectedEmotion = parseEmotion(from: qwenResult.emotion)
        let finalEmotion = detectedEmotion ?? emotion

        let imagePrompt = buildImagePrompt(transcript: transcript, emotion: finalEmotion)
        var imageData: Data?
        do {
            imageData = try await client.generateImage(prompt: imagePrompt)
        } catch {
            print("Image generation failed, using placeholder: \(error)")
            imageData = generatePlaceholderImage(emotion: finalEmotion)
        }

        return DreamContent(
            imageData: imageData,
            poem: qwenResult.poem,
            reflectionQuestion: qwenResult.reflectionQuestion,
            worldName: qwenResult.worldName,
            symbols: qwenResult.symbols,
            detectedEmotion: detectedEmotion
        )
    }

    // MARK: - Fallback Content

    private func generateFallbackContent(emotion: DreamEmotion) -> DreamContent {
        let artStyle = UserPreferences.shared.artStyle
        let poems = fallbackPoems(emotion: emotion, style: artStyle)

        let questions: [String] = [
            "在这个梦中，什么让你感到最安心？",
            "如果可以回到梦里，你最想改变什么？",
            "梦中的那个人，是否代表了你内心的某个声音？",
            "这个梦想告诉你什么关于此刻生活的信息？",
            "梦境中的颜色让你联想到了什么？"
        ]

        let worlds = ["浮光之境", "星河彼岸", "云上花园", "月影深处", "梦的尽头"]
        let symbolSets = [
            ["月亮", "水", "光"],
            ["飞翔", "门", "钥匙"],
            ["花", "雨", "镜子"],
            ["星辰", "路", "桥"],
            ["风", "树", "鸟"]
        ]

        let poem = poems.randomElement() ?? "梦的碎片在指间散落\n化作一缕微光"
        let question = questions.randomElement() ?? "这个梦想告诉你什么？"
        let world = worlds.randomElement() ?? "梦境"
        let symbols = symbolSets.randomElement() ?? ["梦"]
        let imageData = generatePlaceholderImage(emotion: emotion)

        return DreamContent(
            imageData: imageData,
            poem: poem,
            reflectionQuestion: question,
            worldName: world,
            symbols: symbols,
            detectedEmotion: nil
        )
    }

    /// 根据艺术风格和情绪返回不同风格的备选诗句
    private func fallbackPoems(emotion: DreamEmotion, style: ArtStyle) -> [String] {
        switch style {
        case .inkWash:
            return inkWashPoems(emotion: emotion)
        case .japaneseAesthetic:
            return japanesePoems(emotion: emotion)
        case .minimalist:
            return minimalistPoems(emotion: emotion)
        default:
            return defaultPoems(emotion: emotion)
        }
    }

    private func defaultPoems(emotion: DreamEmotion) -> [String] {
        switch emotion {
        case .serenity:
            return [
                "月光洒落在静谧的湖面\n涟漪轻抚着沉睡的星辰\n风带来远方的低语",
                "云朵编织的摇篮里\n时间放慢了脚步\n我听见花开的声音"
            ]
        case .melancholy:
            return [
                "雨落在记忆的窗台\n模糊了那年的轮廓\n一个再也回不去的拥抱",
                "旧照片泛黄的边角\n藏着说不出的思念\n月光拉长了离别的距离"
            ]
        case .anxiety:
            return [
                "时钟的指针追逐着我\n走廊没有尽头\n钥匙藏在梦的缝隙里",
                "风暴中的纸飞机\n颤抖着寻找方向\n在混沌中等待黎明"
            ]
        case .hope:
            return [
                "破晓时分的第一缕光\n穿透了漫长的黑夜\n春天正从远方走来",
                "星河的尽头有一扇门\n钥匙就在手心发光\n靠近那个期待已久的明天"
            ]
        case .whimsy:
            return [
                "鲸鱼在云端游泳\n月亮是它的玩伴\n我骑着纸鹤飞过彩虹",
                "时钟倒着走\n猫咪会说话\n花朵在歌唱"
            ]
        }
    }

    private func inkWashPoems(emotion: DreamEmotion) -> [String] {
        switch emotion {
        case .serenity:
            return [
                "远山含黛水含烟\n一叶扁舟入画眠",
                "松风过处无人语\n月照寒潭鹤自闲"
            ]
        case .melancholy:
            return [
                "烟雨楼台旧梦痕\n落花流水不知门",
                "孤灯残墨忆旧游\n满纸烟霞散不收"
            ]
        case .anxiety:
            return [
                "急墨乱山风雨声\n云深不见旧时城",
                "枯枝如铁夜如磐\n浓墨重处梦未安"
            ]
        case .hope:
            return [
                "淡墨初开见春山\n一枝红杏出云间",
                "破雾孤帆天际来\n江天一色万里开"
            ]
        case .whimsy:
            return [
                "鱼跃墨池化龙去\n山中仙鹤踏云归",
                "泼墨成仙人不识\n半幅残卷梦中飞"
            ]
        }
    }

    private func japanesePoems(emotion: DreamEmotion) -> [String] {
        switch emotion {
        case .serenity:
            return [
                "樱瓣落满肩\n石庭水纹静\n风铃一声远",
                "枯山水无波\n苔痕深处\n时光在呼吸"
            ]
        case .melancholy:
            return [
                "纸伞合拢时\n雨滴还在伞面\n画最后一个圆",
                "信笺已泛黄\n窗外那棵樱树\n不知第几春"
            ]
        case .anxiety:
            return [
                "列车将离站\n月台上的影子\n越拉越长",
                "迷路在巷中\n每扇门都很像\n没有一扇开"
            ]
        case .hope:
            return [
                "雪融之后\n溪水第一次\n学会歌唱",
                "乌云散去的瞬间\n富士山顶\n金光一闪"
            ]
        case .whimsy:
            return [
                "猫从月亮上跳下\n尾巴扫过银河\n星星掉了几颗",
                "龙猫打了个哈欠\n森林抖了抖\n蘑菇长高三寸"
            ]
        }
    }

    private func minimalistPoems(emotion: DreamEmotion) -> [String] {
        switch emotion {
        case .serenity:
            return ["静", "呼吸之间\n天地已白"]
        case .melancholy:
            return ["空椅", "雨停了\n伞还开着"]
        case .anxiety:
            return ["门后有门", "走\n走\n走不到"]
        case .hope:
            return ["裂缝里\n光", "种子不问天气"]
        case .whimsy:
            return ["鱼飞了", "影子自己\n去散步了"]
        }
    }

    // MARK: - Image Prompt

    private func buildImagePrompt(transcript: String, emotion: DreamEmotion) -> String {
        let artStyle = UserPreferences.shared.artStyle
        let stylePrefix = getStylePrefix(for: artStyle)
        let emotionDescription = getEmotionDescription(for: emotion, style: artStyle)
        let styleSuffix = getStyleSuffix(for: artStyle)

        return "\(transcript). \(stylePrefix), \(emotionDescription), \(styleSuffix), dreamlike quality, no text, no watermark"
    }

    private func getStylePrefix(for style: ArtStyle) -> String {
        switch style {
        case .impressionist:
            return "Impressionist oil painting"
        case .japaneseAesthetic:
            return "Japanese aesthetic art with impressionist influences"
        case .surreal:
            return "Surrealist dreamscape painting"
        case .romantic:
            return "Romantic era painting with emotional depth"
        case .minimalist:
            return "Minimalist composition with refined aesthetics"
        case .inkWash:
            return "Traditional Chinese ink wash painting (水墨画), sumi-e style"
        }
    }

    private func getEmotionDescription(for emotion: DreamEmotion, style: ArtStyle) -> String {
        switch (style, emotion) {
        // Impressionist
        case (.impressionist, .serenity):
            return "serene atmosphere, soft diffused light, in the style of Claude Monet's water lilies, gentle color harmony, visible brushstrokes"
        case (.impressionist, .melancholy):
            return "melancholic mood, muted tones, rain-washed light, in the style of Edgar Degas's intimate scenes, subtle emotional depth"
        case (.impressionist, .anxiety):
            return "restless energy, swirling forms, dramatic contrasts, in the style of Edvard Munch's expressive landscapes, turbulent brushstrokes"
        case (.impressionist, .hope):
            return "warm golden light, luminous sky, in the style of Pierre-Auguste Renoir's sun-dappled scenes, radiant uplifting palette"
        case (.impressionist, .whimsy):
            return "fantastical vivid colors, playful composition, in the style of Marc Chagall's dreamlike floating figures, whimsical wonder"

        // Japanese aesthetic
        case (.japaneseAesthetic, .serenity):
            return "serene zen garden aesthetic, soft bokeh background, delicate pastel tones, gentle natural light filtering through, subtle color harmony, quiet contemplation"
        case (.japaneseAesthetic, .melancholy):
            return "melancholic mono no aware (beauty of impermanence), muted tones, soft rain atmosphere, nostalgic haze, gentle sadness, cinematic lighting"
        case (.japaneseAesthetic, .anxiety):
            return "restless energy with Japanese expressionism, atmospheric tension, dramatic yet refined composition, anime-influenced dramatic lighting"
        case (.japaneseAesthetic, .hope):
            return "warm golden hour light, ethereal sky with kawaii softness, hopeful dawn atmosphere, Studio Ghibli-inspired warmth, radiant palette, gentle optimism"
        case (.japaneseAesthetic, .whimsy):
            return "fantastical Japanese fantasy aesthetic, vivid yet harmonious colors, playful composition, Hayao Miyazaki's magical realism, delicate details"

        // Surreal
        case (.surreal, .serenity):
            return "serene impossible geometry, floating elements, Salvador Dalí's dreamscapes, soft surreal lighting, peaceful paradoxes"
        case (.surreal, .melancholy):
            return "melancholic surrealism, distorted memories, René Magritte's mysterious atmosphere, haunting beauty, emotional symbolism"
        case (.surreal, .anxiety):
            return "anxious surrealism, fragmented reality, Francis Bacon's raw emotion, unsettling yet captivating, psychological tension"
        case (.surreal, .hope):
            return "hopeful surrealism, transcendent imagery, uplifting impossible scenes, bright symbolic elements, optimistic transformation"
        case (.surreal, .whimsy):
            return "whimsical surrealism, playful impossible worlds, Joan Miró's joyful abstraction, magical transformations, delightful strangeness"

        // Romantic
        case (.romantic, .serenity):
            return "serene romantic landscape, Caspar David Friedrich's contemplative nature, soft atmospheric perspective, peaceful grandeur"
        case (.romantic, .melancholy):
            return "melancholic romanticism, J.M.W. Turner's emotional storms, dramatic sky, nostalgic atmosphere, passionate sadness"
        case (.romantic, .anxiety):
            return "anxious romantic drama, turbulent nature, William Blake's visionary intensity, powerful contrasts, emotional turmoil"
        case (.romantic, .hope):
            return "hopeful romantic landscape, John Constable's radiant countryside, warm light breaking through, uplifting nature, emotional renewal"
        case (.romantic, .whimsy):
            return "whimsical romanticism, fairy tale atmosphere, Thomas Cole's imaginative landscapes, magical realism, enchanted nature"

        // Minimalist
        case (.minimalist, .serenity):
            return "serene minimalism, clean composition, vast negative space, subtle color palette, zen simplicity, peaceful emptiness"
        case (.minimalist, .melancholy):
            return "melancholic minimalism, sparse elements, muted tones, emotional restraint, contemplative emptiness, quiet sadness"
        case (.minimalist, .anxiety):
            return "anxious minimalism, tense simplicity, stark contrasts, geometric tension, restrained chaos, psychological edge"
        case (.minimalist, .hope):
            return "hopeful minimalism, light-filled space, optimistic geometry, soft color accents, uplifting simplicity, radiant clarity"
        case (.minimalist, .whimsy):
            return "whimsical minimalism, playful shapes, limited color palette with joy, geometric delight, simple yet magical"

        // Ink Wash 水墨
        case (.inkWash, .serenity):
            return "serene Chinese landscape, misty mountains and still water, xieyi freehand brushwork, inspired by Ma Yuan and Ni Zan, vast empty space, meditative calm"
        case (.inkWash, .melancholy):
            return "melancholic ink wash, solitary figure in vast landscape, autumn trees with sparse leaves, rain-soaked atmosphere, Bada Shanren's lonely birds, wistful emptiness"
        case (.inkWash, .anxiety):
            return "turbulent ink splashes, jagged cliff faces, storm clouds in black ink, wild cursive brushstrokes, Zhang Daqian's splashed-ink technique, raw emotional energy"
        case (.inkWash, .hope):
            return "spring returning to the mountains, plum blossoms breaking through snow, morning mist clearing to reveal peaks, Qi Baishi's vivid life force, ink wash with subtle warm color accents"
        case (.inkWash, .whimsy):
            return "fantastical ink wash, mythical creatures among clouds, playful brushwork, Wu Guanzhong's abstract ink landscapes, whimsical immortals riding cranes, dreamlike mountain realms"
        }
    }

    private func getStyleSuffix(for style: ArtStyle) -> String {
        switch style {
        case .impressionist:
            return "visible brushstrokes, atmospheric perspective, natural light play"
        case .japaneseAesthetic:
            return "soft focus, shallow depth of field, cinematic composition, seasonal ambiance"
        case .surreal:
            return "dreamlike logic, symbolic elements, mysterious atmosphere, imaginative details"
        case .romantic:
            return "dramatic lighting, emotional color palette, majestic composition, nature's power"
        case .minimalist:
            return "clean lines, negative space, restrained palette, essential forms only"
        case .inkWash:
            return "rice paper texture, ink gradation from dense to light, deliberate empty space, brush stroke visible, monochrome with minimal color accents"
        }
    }

    // MARK: - JSON Extraction

    private func extractJSON(from text: String) -> String {
        var cleaned = text

        if let thinkRange = cleaned.range(of: "<think>[\\s\\S]*?</think>", options: .regularExpression) {
            cleaned.removeSubrange(thinkRange)
        }

        cleaned = cleaned
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")

        if let start = cleaned.firstIndex(of: "{"),
           let end = cleaned.lastIndex(of: "}") {
            cleaned = String(cleaned[start...end])
        }

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseEmotion(from emotionString: String?) -> DreamEmotion? {
        guard let emotionString = emotionString?.lowercased() else { return nil }

        switch emotionString {
        case "serenity":
            return .serenity
        case "melancholy":
            return .melancholy
        case "anxiety":
            return .anxiety
        case "hope":
            return .hope
        case "whimsy":
            return .whimsy
        default:
            return nil
        }
    }

    // MARK: - Placeholder Image

    private func generatePlaceholderImage(emotion: DreamEmotion) -> Data? {
        let size = CGSize(width: 400, height: 533)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let colors = emotion.gradient.map { UIColor($0) }
            let cgColors = colors.map { $0.cgColor }
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: cgColors as CFArray,
                locations: [0, 0.5, 1]
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
        return image.jpegData(compressionQuality: 0.8)
    }
}
