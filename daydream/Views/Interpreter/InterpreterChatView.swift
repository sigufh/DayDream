import SwiftUI
import SwiftData

// MARK: - 聊天消息列表（嵌入到页面内容中）
struct ChatMessagesList: View {
    @Bindable var viewModel: InterpreterChatViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
            if !viewModel.messages.isEmpty {
                Text("AI 对话")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, DreamSpacing.md)

                VStack(spacing: DreamSpacing.md) {
                    ForEach(viewModel.messages) { message in
                        MessageCard(message: message)
                    }

                    if viewModel.isSending {
                        HStack(spacing: DreamSpacing.sm) {
                            ProgressView()
                                .tint(.white.opacity(0.6))
                            Text("AI 正在思考...")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DreamSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, DreamSpacing.md)
                    }
                }
            }
        }
    }
}

// MARK: - 消息卡片（使用与占卜结果相同的样式）
private struct MessageCard: View {
    let message: InterpreterChatViewModel.ChatMessage

    var body: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
            // 消息头部
            HStack {
                Image(systemName: message.isUser ? "person.circle.fill" : "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(message.isUser ? Color.auroraLavender : .white.opacity(0.7))

                Text(message.isUser ? "你" : "说书人")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            }

            // 消息内容
            Text(message.content)
                .font(.system(size: 14, weight: .light, design: message.isUser ? .default : .serif))
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
        }
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(message.isUser ? Color.auroraLavender.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            message.isUser ? Color.auroraLavender.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, DreamSpacing.md)
    }
}

// MARK: - 固定底部输入框
struct ChatInputBar: View {
    @Bindable var viewModel: InterpreterChatViewModel
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @Query(sort: \Divination.date, order: .reverse) private var divinations: [Divination]

    var body: some View {
        HStack(spacing: DreamSpacing.sm) {
            // AI 图标
            Image(systemName: "sparkles")
                .font(.system(size: 16))
                .foregroundStyle(Color.auroraLavender.opacity(0.8))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )

            // 文本输入框
            TextField("问问说书人...", text: $viewModel.inputText, axis: .vertical)
                .lineLimit(1...4)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .padding(.horizontal, DreamSpacing.md)
                .padding(.vertical, DreamSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .disabled(viewModel.isSending)

            // 发送按钮
            Button {
                Task {
                    await viewModel.sendMessage(dreams: dreams, divinations: divinations)
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                        Color.white.opacity(0.3) : Color.auroraLavender
                    )
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
        }
        .padding(.horizontal, DreamSpacing.md)
        .padding(.vertical, DreamSpacing.md)
    }
}
