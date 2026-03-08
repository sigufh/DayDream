import SwiftUI
import SwiftData

@Observable
final class InterpreterChatViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isSending: Bool = false

    struct ChatMessage: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp: Date = Date()
    }

    private let client = DashScopeClient()

    func sendMessage(dreams: [Dream], divinations: [Divination]) async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = inputText
        inputText = ""

        // 添加用户消息
        messages.append(ChatMessage(content: userMessage, isUser: true))

        isSending = true
        defer { isSending = false }

        // 构建上下文
        let context = buildContext(dreams: dreams, divinations: divinations)

        // 调用AI
        let aiResponse = await getAIResponse(userMessage: userMessage, context: context)

        // 添加AI回复
        messages.append(ChatMessage(content: aiResponse, isUser: false))
    }

    private func buildContext(dreams: [Dream], divinations: [Divination]) -> String {
        var context = ""

        // 添加最近的梦境
        if !dreams.isEmpty {
            context += "用户最近的梦境：\n"
            for (index, dream) in dreams.prefix(5).enumerated() {
                context += "\n梦境\(index + 1)（\(dream.createdAt.formatted(date: .abbreviated, time: .omitted))）：\n"
                context += "内容：\(dream.transcript)\n"
                context += "意象：\(dream.symbols.joined(separator: "、"))\n"
                context += "情绪：\(dream.emotion.displayName)\n"
            }
        }

        // 添加最近的占卜记录
        if !divinations.isEmpty {
            context += "\n\n用户最近的占卜记录：\n"
            for (index, divination) in divinations.prefix(5).enumerated() {
                context += "\n占卜\(index + 1)（\(divination.date.formatted(date: .abbreviated, time: .omitted))）：\n"
                if let hexagramName = divination.hexagramName {
                    context += "卦象：【\(hexagramName)】\n"
                }
                context += "解读：\(divination.interpretation.prefix(100))...\n"
            }
        }

        return context
    }

    private func getAIResponse(userMessage: String, context: String) async -> String {
        if APIConfig.hasValidAPIKey {
            do {
                let systemPrompt = """
                你是一位精通东西方神秘学的智慧导师，擅长解梦、易经占卜和塔罗牌解读。
                用户在使用梦境日记应用，你可以访问他们的梦境记录和占卜历史。

                你的职责：
                - 回答用户关于梦境、占卜、人生困惑的问题
                - 结合用户的梦境和占卜记录给出深入的洞察
                - 用温暖、神秘而富有智慧的语言风格
                - 适时引用周公解梦、易经或塔罗的经典智慧
                - 给出实用的生活建议

                语言风格：
                - 既有古典雅致的诗意，又易于理解
                - 平衡神秘学与心理学视角
                - 鼓励用户探索内在智慧

                回复要简洁（150字以内），直接回答问题，不要加任何前缀。
                """

                let fullMessage = context.isEmpty ? userMessage : "\(context)\n\n用户问题：\(userMessage)"

                return try await client.chat(
                    system: systemPrompt,
                    userMessage: fullMessage,
                    maxTokens: 400
                )
            } catch {
                print("Chat API failed: \(error)")
                return "抱歉，我现在无法连接。不过我一直在这里倾听你的心声。🌙"
            }
        }

        return getFallbackResponse(userMessage: userMessage)
    }

    private func getFallbackResponse(userMessage: String) -> String {
        let lowercased = userMessage.lowercased()

        // 简单的关键词匹配
        if lowercased.contains("梦") || lowercased.contains("做梦") {
            return "梦境是潜意识的语言。每个梦境都有其独特的意义，建议你记录下梦的细节，反复品味其中的意象和情绪。"
        } else if lowercased.contains("卦") || lowercased.contains("占卜") || lowercased.contains("易经") {
            return "易经的智慧在于变化之道。卦象不是宿命，而是对当前能量状态的映照。顺应变化，守正待时。"
        } else if lowercased.contains("塔罗") {
            return "塔罗牌是灵魂的镜子。它不预测未来，而是揭示你内在的真实状态。倾听牌面的指引，答案早已在你心中。"
        } else if lowercased.contains("焦虑") || lowercased.contains("担心") || lowercased.contains("害怕") {
            return "焦虑往往源于对未知的恐惧。试着将注意力带回当下，深呼吸，感受此刻的存在。一切都会过去。"
        } else if lowercased.contains("迷茫") || lowercased.contains("困惑") {
            return "迷茫是探索的开始。当你不知道方向时，不妨静下来，倾听内心的声音。答案会在沉静中自然浮现。"
        } else {
            return "感谢你的分享。每个问题都是一次自我探索的机会。不妨从你的梦境和占卜记录中寻找线索，或许会有新的发现。✨"
        }
    }

    func clearHistory() {
        messages.removeAll()
    }
}
