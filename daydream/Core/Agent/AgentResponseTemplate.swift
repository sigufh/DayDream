import Foundation

enum AgentQuestionType: String, Hashable {
    case explicitDreamReading
    case tarotReflection
    case contextualReflection
    case generalGuidance
}

struct AgentResponseTemplate {
    struct Section: Hashable {
        let title: String
        let sourceIDs: [String]
        let fallback: String
    }

    let questionType: AgentQuestionType
    let sections: [Section]
    let requiresStructuredOutput: Bool
}

enum AgentTemplateRegistry {
    static func questionType(for input: String) -> AgentQuestionType {
        if hasDreamReadingIntent(for: input) {
            return .explicitDreamReading
        }

        if hasTarotKnowledgeIntent(for: input) {
            return .tarotReflection
        }

        if hasContextualIntent(for: input) {
            return .contextualReflection
        }

        return .generalGuidance
    }

    static func hasDreamReadingIntent(for input: String) -> Bool {
        let normalized = input.lowercased()
        let explicitPhrases = [
            "解梦",
            "这个梦",
            "我的梦",
            "这梦",
            "今天的梦",
            "今日之梦",
            "昨晚的梦",
            "刚才的梦",
            "梦到",
            "梦见",
            "梦什么意思",
            "梦意味着什么",
            "这个梦怎么解",
            "这个梦代表什么"
        ]
        let meaningPhrases = [
            "什么意思",
            "意味着什么",
            "怎么解",
            "代表什么",
            "怎么理解",
            "预示什么",
            "解读",
            "分析",
            "看看",
            "说说",
            "讲讲"
        ]

        if explicitPhrases.contains(where: normalized.contains) {
            return true
        }

        if containsDreamContext(in: normalized) && ["解读", "分析", "看看", "说说", "讲讲", "聊聊"].contains(where: normalized.contains) {
            return true
        }

        return containsDreamContext(in: normalized) && meaningPhrases.contains(where: normalized.contains)
    }

    static func hasTarotKnowledgeIntent(for input: String) -> Bool {
        let normalized = input.lowercased()
        let knowledgePhrases = [
            "是什么",
            "什么意思",
            "含义",
            "区别",
            "怎么理解",
            "介绍",
            "知识",
            "规则",
            "牌义",
            "代表什么",
            "如何解读"
        ]

        return containsTarotTerms(in: normalized) && knowledgePhrases.contains(where: normalized.contains) && !hasDreamReadingIntent(for: input)
    }

    static func hasContextualIntent(for input: String) -> Bool {
        let normalized = input.lowercased()
        return ["天气", "地点", "节气", "季节", "当下", "环境", "时令", "时节"].contains(where: normalized.contains)
    }

    static func containsDreamContext(in input: String) -> Bool {
        ["梦", "梦境", "梦到", "梦见", "潜意识", "意象"].contains(where: input.contains)
    }

    static func containsTarotTerms(in input: String) -> Bool {
        [
            "塔罗",
            "牌阵",
            "牌义",
            "正位",
            "逆位",
            "抽牌",
            "愚者",
            "恋人",
            "月亮",
            "命运之轮",
            "圣杯",
            "宝剑",
            "权杖",
            "星币"
        ].contains(where: input.contains)
    }

    static func requestsTarotDraw(for input: String) -> Bool {
        let normalized = input.lowercased()
        return [
            "帮我抽牌",
            "抽一张",
            "抽牌看看",
            "后台抽牌",
            "替我抽牌",
            "如果抽一张",
            "来一张牌"
        ].contains(where: normalized.contains)
    }

    static func requiresFormalTarotDraw(for input: String) -> Bool {
        let normalized = input.lowercased()
        return hasDreamReadingIntent(for: input)
            || [
                "帮我抽牌",
                "抽一张",
                "抽牌看看",
                "替我抽牌",
                "来一张牌",
                "塔罗"
            ].contains(where: normalized.contains)
    }

    static func template(for type: AgentQuestionType) -> AgentResponseTemplate {
        switch type {
        case .explicitDreamReading:
            return AgentResponseTemplate(
                questionType: type,
                sections: [
                    .init(
                        title: "抽牌结果",
                        sourceIDs: ["tarot_draw_preview", "tarot_knowledge_lookup", "tarot_retrieval", "dream_interpretation"],
                        fallback: "这次没有拿到可用牌面，我先只按梦境本身来判断。"
                    ),
                    .init(
                        title: "梦境记忆",
                        sourceIDs: ["dream_memory_lookup", "dream_retrieval", "dream_interpretation"],
                        fallback: "目前没有检索到足够接近的旧梦，这次主要依据你眼前这条梦来判断。"
                    ),
                    .init(
                        title: "建议行动",
                        sourceIDs: ["action_guidance", "environment_context", "seasonal_context"],
                        fallback: "先把这次梦里的核心意象和醒来后的第一情绪记下来，接下来三天观察它是否再次出现。"
                    )
                ],
                requiresStructuredOutput: true
            )

        case .tarotReflection:
            return AgentResponseTemplate(
                questionType: type,
                sections: [
                    .init(
                        title: "核心牌义",
                        sourceIDs: ["tarot_draw_preview", "tarot_knowledge_lookup", "tarot_retrieval"],
                        fallback: "这次先按你提到的塔罗主题来判断，不额外生成牌面。"
                    ),
                    .init(
                        title: "规则说明",
                        sourceIDs: ["tarot_knowledge_lookup", "tarot_retrieval"],
                        fallback: "当前先按通用塔罗规则说明这张牌或这个概念的常见解读方式。"
                    ),
                    .init(
                        title: "使用建议",
                        sourceIDs: ["action_guidance"],
                        fallback: "先记录你最在意的那张牌，以及它对应到现实里的一个处境。"
                    )
                ],
                requiresStructuredOutput: true
            )

        case .contextualReflection:
            return AgentResponseTemplate(
                questionType: type,
                sections: [
                    .init(
                        title: "环境线索",
                        sourceIDs: ["environment_context", "seasonal_context"],
                        fallback: "当前没有足够环境信息，我先不强行引入现实变量。"
                    ),
                    .init(
                        title: "梦境关联",
                        sourceIDs: ["dream_memory_lookup", "dream_retrieval", "dream_interpretation"],
                        fallback: "这次更适合从你当前问题和梦境主题本身理解。"
                    ),
                    .init(
                        title: "建议",
                        sourceIDs: ["action_guidance"],
                        fallback: "先观察现实环境变化是否会触发相似梦境。"
                    )
                ],
                requiresStructuredOutput: true
            )

        case .generalGuidance:
            return AgentResponseTemplate(
                questionType: type,
                sections: [],
                requiresStructuredOutput: false
            )
        }
    }

    static func renderFallback(
        template: AgentResponseTemplate,
        skillResults: [SkillResult],
        toolResults: [AgentToolResult]
    ) -> String {
        guard template.requiresStructuredOutput else {
            return renderGeneralFallback(skillResults: skillResults, toolResults: toolResults)
        }

        let skillMap = Dictionary(uniqueKeysWithValues: skillResults.map { ($0.skillID, $0.content) })
        let toolMap = Dictionary(uniqueKeysWithValues: toolResults.map { ($0.toolID, $0.content) })

        return template.sections.map { section in
            let content = sectionContent(section: section, skillMap: skillMap, toolMap: toolMap)

            return "\(section.title)：\(content)"
        }
        .joined(separator: "\n\n")
    }

    static func matchesRequiredSections(_ content: String, template: AgentResponseTemplate) -> Bool {
        guard template.requiresStructuredOutput else { return true }
        return template.sections.allSatisfy { section in
            content.contains("\(section.title)：") || content.contains("\(section.title):")
        }
    }

    private static func renderGeneralFallback(skillResults: [SkillResult], toolResults: [AgentToolResult]) -> String {
        var lines: [String] = []
        let skillMap = Dictionary(uniqueKeysWithValues: skillResults.map { ($0.skillID, $0.content) })
        let toolMap = Dictionary(uniqueKeysWithValues: toolResults.map { ($0.toolID, $0.content) })

        if let memory = skillMap["dream_retrieval"] {
            lines.append("我先看了你最近的梦境记忆，里面确实有相近的情绪线索。")
            lines.append(memory)
        }

        if let tarot = skillMap["tarot_retrieval"] {
            lines.append("塔罗规则里，与你问题最接近的是这些象征。")
            lines.append(tarot)
        }

        if let interpretation = skillMap["dream_interpretation"] {
            lines.append("综合来看，\(excerpt(from: interpretation, limit: 100))")
        }

        if let seasonal = toolMap["seasonal_context"] {
            lines.append(seasonal)
        }

        if let environment = toolMap["environment_context"], !environment.contains("不可用") {
            lines.append(environment)
        }

        if let draw = toolMap["tarot_draw_preview"] {
            lines.append(draw)
        }

        if let action = skillMap["action_guidance"] {
            lines.append(action)
        }

        if lines.isEmpty {
            return "你可以把问题再说得更具体一些，我会继续替你检索相关梦境与规则。"
        }

        return lines.joined(separator: "\n")
    }

    private static func sectionContent(
        section: AgentResponseTemplate.Section,
        skillMap: [String: String],
        toolMap: [String: String]
    ) -> String {
        let contents = section.sourceIDs.compactMap { sourceID in
            toolMap[sourceID] ?? skillMap[sourceID]
        }
        .reduce(into: [String]()) { partial, item in
            guard !partial.contains(item) else { return }
            partial.append(item)
        }

        guard !contents.isEmpty else {
            return section.fallback
        }

        if contents.count == 1 {
            return contents[0]
        }

        return contents.prefix(2).joined(separator: " ")
    }

    private static func excerpt(from text: String, limit: Int) -> String {
        text.count > limit ? String(text.prefix(limit)) + "…" : text
    }
}
