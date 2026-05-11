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

    func sendMessage(dreams: [Dream], divinations: [Divination]) async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = inputText
        inputText = ""

        // 添加用户消息
        messages.append(ChatMessage(content: userMessage, isUser: true))

        isSending = true
        defer { isSending = false }

        let response = await AgentOrchestrator.shared.respond(
            userInput: userMessage,
            dreams: dreams,
            divinations: divinations
        )

        // 添加AI回复
        messages.append(ChatMessage(content: response.content, isUser: false))
    }

    func clearHistory() {
        messages.removeAll()
    }
}
