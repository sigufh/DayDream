import Foundation
import CoreLocation

enum AgentToolCapability: String, Codable, Hashable {
    case dreamMemoryLookup
    case tarotKnowledgeLookup
    case contextSnapshot
    case seasonalContext
    case tarotDraw
}

enum AgentToolInputSchema: String, Codable, Hashable {
    case textQuery
    case environmentRequest
    case divinationRequest
}

enum AgentToolOutputSchema: String, Codable, Hashable {
    case retrievalBundle
    case contextBundle
    case drawBundle
}

struct AgentToolDefinition: Identifiable, Codable, Hashable {
    let id: String
    let displayName: String
    let description: String
    let capability: AgentToolCapability
    let inputSchema: AgentToolInputSchema
    let outputSchema: AgentToolOutputSchema
    let isReadOnly: Bool
}

struct AgentToolRequest: Hashable {
    let userInput: String
    let dreams: [Dream]
    let divinations: [Divination]
    let keywords: [String]
}

struct AgentToolReference: Identifiable, Hashable {
    let id: String
    let title: String
    let excerpt: String
    let badge: String
}

struct AgentToolResult: Hashable {
    let toolID: String
    let title: String
    let content: String
    let references: [AgentToolReference]
    let metadata: [String: String]
}

struct AgentToolExecutionRecord: Identifiable, Hashable {
    let id = UUID()
    let toolID: String
    let toolName: String
    let capability: AgentToolCapability
    let score: Int
}

protocol AgentTool {
    var definition: AgentToolDefinition { get }
    var keywords: [String] { get }
    func execute(request: AgentToolRequest) async -> AgentToolResult
}

protocol AgentToolExecutor {
    func execute(_ tool: any AgentTool, request: AgentToolRequest) async -> AgentToolResult
}

struct DefaultAgentToolExecutor: AgentToolExecutor {
    func execute(_ tool: any AgentTool, request: AgentToolRequest) async -> AgentToolResult {
        await tool.execute(request: request)
    }
}

struct DreamMemoryLookupTool: AgentTool {
    let definition = AgentToolDefinition(
        id: "dream_memory_lookup",
        displayName: "梦境记忆查询",
        description: "检索用户历史梦境，找出相似主题、情绪和意象",
        capability: .dreamMemoryLookup,
        inputSchema: .textQuery,
        outputSchema: .retrievalBundle,
        isReadOnly: true
    )

    let keywords = ["梦", "梦境", "意象", "反复", "最近", "记忆", "情绪", "潜意识", "主题"]

    func execute(request: AgentToolRequest) async -> AgentToolResult {
        let results = await DreamMemoryIndexer.shared.search(query: request.userInput, dreams: request.dreams, topK: 3)

        if results.isEmpty {
            return AgentToolResult(
                toolID: definition.id,
                title: definition.displayName,
                content: "没有检索到足够接近的历史梦境。",
                references: [],
                metadata: ["matches": "0"]
            )
        }

        let references = results.map {
            AgentToolReference(
                id: $0.id,
                title: $0.document.title,
                excerpt: excerpt(from: $0.document.content),
                badge: "梦境记忆"
            )
        }

        let content = results.enumerated().map { index, result in
            let emotion = result.document.metadata["emotionName"] ?? "未知情绪"
            return "关联梦境\(index + 1)：\(result.document.title)，情绪偏\(emotion)，内容涉及\(excerpt(from: result.document.content, limit: 42))。"
        }
        .joined(separator: " ")

        return AgentToolResult(
            toolID: definition.id,
            title: definition.displayName,
            content: content,
            references: references,
            metadata: ["matches": "\(results.count)"]
        )
    }

    private func excerpt(from text: String, limit: Int = 70) -> String {
        let clean = text.replacingOccurrences(of: "\n", with: " ")
        return clean.count > limit ? String(clean.prefix(limit)) + "…" : clean
    }
}

struct TarotKnowledgeLookupTool: AgentTool {
    let definition = AgentToolDefinition(
        id: "tarot_knowledge_lookup",
        displayName: "塔罗规则查询",
        description: "检索塔罗牌义、正逆位信息和牌阵规则",
        capability: .tarotKnowledgeLookup,
        inputSchema: .textQuery,
        outputSchema: .retrievalBundle,
        isReadOnly: true
    )

    let keywords = ["塔罗", "牌", "正位", "逆位", "牌阵", "月亮", "愚者", "恋人", "抽牌"]

    func execute(request: AgentToolRequest) async -> AgentToolResult {
        let results = await TarotKnowledgeIndexer.shared.search(query: request.userInput, topK: 3)

        if results.isEmpty {
            return AgentToolResult(
                toolID: definition.id,
                title: definition.displayName,
                content: "当前没有召回明确牌义。",
                references: [],
                metadata: ["matches": "0"]
            )
        }

        let references = results.map {
            AgentToolReference(
                id: $0.id,
                title: $0.document.title,
                excerpt: excerpt(from: $0.document.content),
                badge: "塔罗规则"
            )
        }

        let content = results.enumerated().map { index, result in
            "规则\(index + 1)：\(result.document.title)，\(excerpt(from: result.document.content, limit: 56))。"
        }
        .joined(separator: " ")

        return AgentToolResult(
            toolID: definition.id,
            title: definition.displayName,
            content: content,
            references: references,
            metadata: ["matches": "\(results.count)"]
        )
    }

    private func excerpt(from text: String, limit: Int = 70) -> String {
        let clean = text.replacingOccurrences(of: "\n", with: " ")
        return clean.count > limit ? String(clean.prefix(limit)) + "…" : clean
    }
}

struct SeasonalContextTool: AgentTool {
    let definition = AgentToolDefinition(
        id: "seasonal_context",
        displayName: "时令节气上下文",
        description: "提供当前日期、节气和季节语境，作为辅助解读背景",
        capability: .seasonalContext,
        inputSchema: .environmentRequest,
        outputSchema: .contextBundle,
        isReadOnly: true
    )

    let keywords = ["今天", "最近", "节气", "季节", "时令", "当下", "时节"]

    func execute(request: AgentToolRequest) async -> AgentToolResult {
        let currentTerm = SolarTerm.currentTerm()
        let dateText = Date().formatted(date: .long, time: .omitted)
        let content = "今天是\(dateText)，当前节气为\(currentTerm.chineseName)，属\(currentTerm.season.rawValue)。可参考意境：\(currentTerm.poem)。"

        return AgentToolResult(
            toolID: definition.id,
            title: definition.displayName,
            content: content,
            references: [],
            metadata: [
                "solarTerm": currentTerm.chineseName,
                "season": currentTerm.season.rawValue
            ]
        )
    }
}

struct EnvironmentContextTool: AgentTool {
    let definition = AgentToolDefinition(
        id: "environment_context",
        displayName: "天气地点上下文",
        description: "读取当前可用的位置与天气信息，作为辅助解读背景",
        capability: .contextSnapshot,
        inputSchema: .environmentRequest,
        outputSchema: .contextBundle,
        isReadOnly: true
    )

    let keywords = ["天气", "地点", "哪里", "位置", "环境", "此刻", "现实", "场景"]

    func execute(request: AgentToolRequest) async -> AgentToolResult {
        let locationManager = LocationManager()
        let weatherService = WeatherService()

        let location = await locationManager.requestLocation()
        var locationName: String?
        if let location {
            locationName = await locationManager.reverseGeocode(location: location)
        }
        await weatherService.fetchWeather(for: location)

        let pieces = [
            locationName.map { "地点：\($0)" },
            weatherService.weatherDescription.map { "天气：\($0)" },
            weatherService.temperature.map { "气温：\(Int($0))°C" }
        ]
        .compactMap { $0 }

        let content: String
        if pieces.isEmpty {
            content = "当前位置或天气不可用，本次不引入现实环境变量。"
        } else {
            content = "现实环境补充：\(pieces.joined(separator: "，"))。"
        }

        return AgentToolResult(
            toolID: definition.id,
            title: definition.displayName,
            content: content,
            references: [],
            metadata: [
                "location": locationName ?? "",
                "weather": weatherService.weatherDescription ?? ""
            ]
        )
    }
}

struct TarotDrawTool: AgentTool {
    let definition = AgentToolDefinition(
        id: "tarot_draw_preview",
        displayName: "后台抽牌预览",
        description: "在不写入历史记录的前提下做一次后台抽牌，用于辅助解读",
        capability: .tarotDraw,
        inputSchema: .divinationRequest,
        outputSchema: .drawBundle,
        isReadOnly: true
    )

    let keywords = ["帮我抽牌", "抽一张", "抽牌", "牌面", "如果抽", "后台抽牌"]

    func execute(request: AgentToolRequest) async -> AgentToolResult {
        if let latestReading = latestTarotReading(from: request.divinations) {
            let content = "正式抽牌结果为\(latestReading.summary)。解读指出：\(latestReading.interpretation)"
            return AgentToolResult(
                toolID: definition.id,
                title: "正式塔罗结果",
                content: content,
                references: latestReading.references,
                metadata: [
                    "drawn": "true",
                    "source": "formal_divination",
                    "spread": latestReading.spread
                ]
            )
        }

        let cards = TarotService.drawCards(count: 1, deckType: .majorOnly)
        guard let card = cards.first else {
            return AgentToolResult(
                toolID: definition.id,
                title: definition.displayName,
                content: "本次未能生成牌面预览。",
                references: [],
                metadata: ["drawn": "false"]
            )
        }

        let orientation = card.isReversed ? "逆位" : "正位"
        let meaning = card.isReversed ? card.card.reversedMeaning : card.card.meaning
        let content = "后台抽牌预览得到 \(card.card.nameChinese)（\(orientation)），含义偏向：\(meaning)。本结果仅作当次辅助，不写入历史。"

        return AgentToolResult(
            toolID: definition.id,
            title: definition.displayName,
            content: content,
            references: [
                AgentToolReference(
                    id: "tarot-preview-\(card.card.name)",
                    title: card.card.nameChinese,
                    excerpt: meaning,
                    badge: orientation
                )
            ],
            metadata: [
                "drawn": "true",
                "card": card.card.nameChinese,
                "orientation": orientation,
                "source": "preview"
            ]
        )
    }

    private func latestTarotReading(from divinations: [Divination]) -> (summary: String, interpretation: String, spread: String, references: [AgentToolReference])? {
        guard let latest = divinations.first(where: {
            !$0.leaves.isEmpty && $0.leaves.contains(where: { $0.contains("：") && ($0.contains("正位") || $0.contains("逆位")) })
        }) else {
            return nil
        }

        let spread = spreadName(for: latest.leaves.count)
        let summary = latest.leaves.joined(separator: "；")
        let references = latest.leaves.prefix(3).map { item in
            let parts = item.split(separator: "：", maxSplits: 1).map(String.init)
            let title = parts.count == 2 ? parts[1] : item
            let badge = parts.first ?? "牌位"
            return AgentToolReference(
                id: "formal-tarot-\(latest.id.uuidString)-\(item)",
                title: title,
                excerpt: latest.interpretation,
                badge: badge
            )
        }

        return (summary, latest.interpretation, spread, references)
    }

    private func spreadName(for count: Int) -> String {
        switch count {
        case 1:
            return TarotService.SpreadType.single.rawValue
        case 3:
            return TarotService.SpreadType.threeCard.rawValue
        case 10:
            return TarotService.SpreadType.celtic.rawValue
        default:
            return "自定义牌阵"
        }
    }
}

enum AgentToolRegistry {
    static let tools: [any AgentTool] = [
        DreamMemoryLookupTool(),
        TarotKnowledgeLookupTool(),
        SeasonalContextTool(),
        EnvironmentContextTool(),
        TarotDrawTool()
    ]

    static func tools(for capability: AgentToolCapability) -> [any AgentTool] {
        tools.filter { $0.definition.capability == capability }
    }
}
