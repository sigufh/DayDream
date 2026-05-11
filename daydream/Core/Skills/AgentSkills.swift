import Foundation

enum SkillInputSchema: String, Codable, Hashable {
    case stylePrompt
    case retrievalQuery
    case interpretationRequest
    case guidanceRequest
}

enum SkillOutputSchema: String, Codable, Hashable {
    case styleGuidance
    case retrievalSummary
    case interpretationSummary
    case actionPlan
}

struct SkillExecutionRequest {
    let context: SkillContext
    let capability: SkillCapability
    let intentKeywords: [String]
}

struct SkillExecutionRecord: Identifiable, Hashable {
    let id = UUID()
    let capability: SkillCapability
    let selectedSkillID: String
    let selectedSkillName: String
    let score: Int
}

protocol SkillExecutor {
    func execute(_ skill: any AppSkill, request: SkillExecutionRequest) async -> SkillResult
}

struct DefaultSkillExecutor: SkillExecutor {
    func execute(_ skill: any AppSkill, request: SkillExecutionRequest) async -> SkillResult {
        await skill.execute(with: request.context)
    }
}

struct SkillDescriptor: Hashable {
    let definition: SkillDefinition
    let inputSchema: SkillInputSchema
    let outputSchema: SkillOutputSchema
    let keywords: [String]
}

protocol AgentRunnableSkill: AppSkill {
    var descriptor: SkillDescriptor { get }
}

struct DreamRetrievalSkill: AgentRunnableSkill {
    let definition = SkillDefinition(
        id: "dream_retrieval",
        displayName: "梦境检索",
        description: "从本地梦境记忆中召回与用户问题最相关的记录",
        category: .retrieval,
        capabilities: [.dreamRetrieval]
    )

    let descriptor = SkillDescriptor(
        definition: SkillDefinition(
            id: "dream_retrieval",
            displayName: "梦境检索",
            description: "从本地梦境记忆中召回与用户问题最相关的记录",
            category: .retrieval,
            capabilities: [.dreamRetrieval]
        ),
        inputSchema: .retrievalQuery,
        outputSchema: .retrievalSummary,
        keywords: ["梦", "梦境", "意象", "反复", "最近", "情绪", "记忆", "潜意识"]
    )

    func execute(with context: SkillContext) async -> SkillResult {
        let results = await DreamMemoryIndexer.shared.search(query: context.userInput, dreams: context.dreams, topK: 3)

        if results.isEmpty {
            return SkillResult(
                skillID: definition.id,
                title: definition.displayName,
                content: "没有检索到足够接近的历史梦境，先以当前问题和近期情绪为主。",
                references: [],
                metadata: [
                    "matches": "0",
                    "inputSchema": descriptor.inputSchema.rawValue,
                    "outputSchema": descriptor.outputSchema.rawValue
                ]
            )
        }

        let references = results.map {
            SkillReference(
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

        return SkillResult(
            skillID: definition.id,
            title: definition.displayName,
            content: content,
            references: references,
            metadata: [
                "matches": "\(results.count)",
                "inputSchema": descriptor.inputSchema.rawValue,
                "outputSchema": descriptor.outputSchema.rawValue
            ]
        )
    }

    private func excerpt(from text: String, limit: Int = 70) -> String {
        let clean = text.replacingOccurrences(of: "\n", with: " ")
        return clean.count > limit ? String(clean.prefix(limit)) + "…" : clean
    }
}

struct TarotRetrievalSkill: AgentRunnableSkill {
    let definition = SkillDefinition(
        id: "tarot_retrieval",
        displayName: "塔罗检索",
        description: "从本地塔罗规则库中召回与问题最相关的牌义与牌阵规则",
        category: .retrieval,
        capabilities: [.tarotRetrieval]
    )

    let descriptor = SkillDescriptor(
        definition: SkillDefinition(
            id: "tarot_retrieval",
            displayName: "塔罗检索",
            description: "从本地塔罗规则库中召回与问题最相关的牌义与牌阵规则",
            category: .retrieval,
            capabilities: [.tarotRetrieval]
        ),
        inputSchema: .retrievalQuery,
        outputSchema: .retrievalSummary,
        keywords: ["塔罗", "牌", "正位", "逆位", "牌阵", "月亮", "愚者", "恋人", "抽牌"]
    )

    func execute(with context: SkillContext) async -> SkillResult {
        let results = await TarotKnowledgeIndexer.shared.search(query: context.userInput, topK: 3)

        if results.isEmpty {
            return SkillResult(
                skillID: definition.id,
                title: definition.displayName,
                content: "当前没有召回明确牌义，保守采用通用塔罗视角，不强行解释。",
                references: [],
                metadata: [
                    "matches": "0",
                    "inputSchema": descriptor.inputSchema.rawValue,
                    "outputSchema": descriptor.outputSchema.rawValue
                ]
            )
        }

        let references = results.map {
            SkillReference(
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

        return SkillResult(
            skillID: definition.id,
            title: definition.displayName,
            content: content,
            references: references,
            metadata: [
                "matches": "\(results.count)",
                "inputSchema": descriptor.inputSchema.rawValue,
                "outputSchema": descriptor.outputSchema.rawValue
            ]
        )
    }

    private func excerpt(from text: String, limit: Int = 70) -> String {
        let clean = text.replacingOccurrences(of: "\n", with: " ")
        return clean.count > limit ? String(clean.prefix(limit)) + "…" : clean
    }
}

struct DreamInterpretationSkill: AgentRunnableSkill {
    let definition = SkillDefinition(
        id: "dream_interpretation",
        displayName: "梦境解读",
        description: "结合当前问题、梦境、占卜和前序检索结果生成解释摘要",
        category: .interpretation,
        capabilities: [.dreamInterpretation]
    )

    let descriptor = SkillDescriptor(
        definition: SkillDefinition(
            id: "dream_interpretation",
            displayName: "梦境解读",
            description: "结合当前问题、梦境、占卜和前序检索结果生成解释摘要",
            category: .interpretation,
            capabilities: [.dreamInterpretation]
        ),
        inputSchema: .interpretationRequest,
        outputSchema: .interpretationSummary,
        keywords: ["为什么", "意味着", "象征", "解读", "梦", "关联", "反复"]
    )

    func execute(with context: SkillContext) async -> SkillResult {
        let latestDream = context.dreams.first
        let latestDivination = context.divinations.first
        let priorByID = Dictionary(uniqueKeysWithValues: context.priorResults.map { ($0.skillID, $0) })

        var content = ""
        if let latestDream {
            content += "最近梦境主题是\(latestDream.worldName ?? "未命名梦境")，情绪为\(latestDream.emotion.displayName)，意象包括\(latestDream.symbols.joined(separator: "、"))。"
        } else {
            content += "用户当前没有可用的梦境记录，解释应更多围绕问题本身。"
        }

        if let hexagramName = latestDivination?.hexagramName {
            content += " 最近一条占卜记录与\(hexagramName)有关，可作为辅助背景。"
        }

        if let memory = priorByID["dream_retrieval"] {
            content += " \(memory.content)"
        }

        if let tarot = priorByID["tarot_retrieval"] {
            content += " \(tarot.content)"
        }

        return SkillResult(
            skillID: definition.id,
            title: definition.displayName,
            content: content,
            references: [],
            metadata: [
                "hasDream": latestDream == nil ? "false" : "true",
                "inputSchema": descriptor.inputSchema.rawValue,
                "outputSchema": descriptor.outputSchema.rawValue
            ]
        )
    }
}

struct ActionGuidanceSkill: AgentRunnableSkill {
    let definition = SkillDefinition(
        id: "action_guidance",
        displayName: "行动建议",
        description: "把梦境/塔罗分析整理成可以执行的下一步建议",
        category: .guidance,
        capabilities: [.actionGuidance]
    )

    let descriptor = SkillDescriptor(
        definition: SkillDefinition(
            id: "action_guidance",
            displayName: "行动建议",
            description: "把梦境/塔罗分析整理成可以执行的下一步建议",
            category: .guidance,
            capabilities: [.actionGuidance]
        ),
        inputSchema: .guidanceRequest,
        outputSchema: .actionPlan,
        keywords: ["怎么办", "建议", "下一步", "计划", "行动", "改善", "如何"]
    )

    func execute(with context: SkillContext) async -> SkillResult {
        let emotion = context.dreams.first?.emotion.displayName ?? "当前情绪"
        let hasTarotContext = context.priorResults.contains(where: {
            ($0.skillID == "tarot_retrieval" || $0.skillID == "tarot_knowledge_lookup" || $0.skillID == "tarot_draw_preview")
            && $0.metadata["matches"] != "0"
        }) || context.priorResults.contains(where: {
            $0.skillID == "tarot_draw_preview" && $0.metadata["drawn"] == "true"
        })
        let seasonalContext = context.priorResults.first(where: { $0.skillID == "seasonal_context" })?.content
        let environmentContext = context.priorResults.first(where: { $0.skillID == "environment_context" })?.content

        var content = "建议先围绕\(emotion)做一件轻量行动：记录触发点、复盘反复意象，并在接下来三天观察是否再次出现。"
        if hasTarotContext {
            content += " 若问题涉及选择，优先比较你最抗拒与最想靠近的两个方向。"
        }
        if let seasonalContext {
            content += " 时令参考上，\(excerpt(from: seasonalContext, limit: 36))"
        }
        if let environmentContext, !environmentContext.contains("不可用") {
            content += " 现实环境方面，\(excerpt(from: environmentContext, limit: 36))"
        }
        if context.userInput.contains("焦虑") || context.userInput.contains("害怕") {
            content += " 今天不要追求完整答案，先降低刺激与信息输入。"
        }

        return SkillResult(
            skillID: definition.id,
            title: definition.displayName,
            content: content,
            references: [],
            metadata: [
                "inputSchema": descriptor.inputSchema.rawValue,
                "outputSchema": descriptor.outputSchema.rawValue
            ]
        )
    }

    private func excerpt(from text: String, limit: Int) -> String {
        let clean = text.replacingOccurrences(of: "\n", with: " ")
        return clean.count > limit ? String(clean.prefix(limit)) + "…" : clean
    }
}
