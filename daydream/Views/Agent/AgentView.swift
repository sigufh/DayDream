import SwiftUI
import SwiftData

struct AgentView: View {
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @Query(sort: \Divination.date, order: .reverse) private var divinations: [Divination]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AgentConversationViewModel()

    private let suggestedPrompts = [
        "最近反复出现的梦意味着什么？",
        "结合我的梦境，给我一个本周行动建议",
        "如果我现在抽到月亮牌，它和我的梦有什么关系？"
    ]

    var body: some View {
        ZStack {
            InterpreterBackground()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: DreamSpacing.lg) {
                        capabilityCard

                        if viewModel.messages.isEmpty {
                            suggestedPromptSection
                        } else {
                            LazyVStack(spacing: DreamSpacing.md) {
                                ForEach(viewModel.messages) { message in
                                    AgentMessageCard(message: message)
                                }
                            }
                        }

                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.horizontal, DreamSpacing.md)
                    .padding(.top, DreamSpacing.md)
                }
                .scrollDismissesKeyboard(.interactively)

                AgentInputBar(
                    inputText: $viewModel.inputText,
                    isSending: viewModel.isSending,
                    onSend: {
                        Task {
                            await viewModel.prepareSend(dreams: dreams, divinations: divinations)
                        }
                    }
                )
            }
        }
        .task {
            await TarotKnowledgeIndexer.shared.ensureIndexed()
        }
        .sheet(isPresented: $viewModel.showTarotSheet) {
            AgentTarotSetupSheet(
                isLoading: viewModel.isPreparingTarotReading,
                onConfirm: { spread, deckType in
                    Task {
                        await viewModel.confirmTarotSetup(
                            spread: spread,
                            deckType: deckType,
                            dreams: dreams,
                            divinations: divinations,
                            modelContext: modelContext
                        )
                    }
                },
                onCancel: {
                    viewModel.cancelTarotSetup()
                }
            )
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(spacing: DreamSpacing.sm) {
            Text("梦境代理")
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundStyle(.white)
                .tracking(4)

            Text("检索梦境，参考牌义，替你归纳答案")
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.top, DreamSpacing.md)
    }

    private var capabilityCard: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
            Text("本页会做什么")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.75))

            Text("我会先检索你的梦境记忆，再按问题调用塔罗规则与解梦分析，最后给出一段更接近你当前处境的回答。")
                .font(.system(size: 14, weight: .light, design: .serif))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private var suggestedPromptSection: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
            Text("你可以这样问")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.65))

            ForEach(suggestedPrompts, id: \.self) { prompt in
                Button {
                    viewModel.inputText = prompt
                } label: {
                    Text(prompt)
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundStyle(.white.opacity(0.86))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DreamSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.auroraLavender.opacity(0.22), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@MainActor
@Observable
final class AgentConversationViewModel {
    struct PendingTarotConfig {
        let prompt: String
        let dreams: [Dream]
        let divinations: [Divination]
    }

    struct Message: Identifiable {
        let id = UUID()
        let isUser: Bool
        let content: String
        let timestamp: Date = Date()
        let expertBadges: [String]
        let references: [AgentReference]
        let executionTrace: [SkillExecutionRecord]
        let toolTrace: [AgentToolExecutionRecord]
    }

    var messages: [Message] = []
    var inputText: String = ""
    var isSending = false
    var showTarotSheet = false
    var isPreparingTarotReading = false
    private var pendingTarotConfig: PendingTarotConfig?

    func prepareSend(dreams: [Dream], divinations: [Divination]) async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        if AgentTemplateRegistry.requiresFormalTarotDraw(for: trimmed) {
            pendingTarotConfig = PendingTarotConfig(
                prompt: trimmed,
                dreams: dreams,
                divinations: divinations
            )
            showTarotSheet = true
            return
        }

        await sendMessage(
            displayContent: trimmed,
            agentInput: trimmed,
            dreams: dreams,
            divinations: divinations
        )
    }

    func confirmTarotSetup(
        spread: TarotService.SpreadType,
        deckType: TarotService.DeckType,
        dreams: [Dream],
        divinations: [Divination],
        modelContext: ModelContext
    ) async {
        guard let pendingTarotConfig else { return }
        isPreparingTarotReading = true
        defer { isPreparingTarotReading = false }

        let reading = await TarotService.createReading(
            spread: spread,
            deckType: deckType,
            dreams: dreams
        )
        let relatedDreamID = pendingTarotConfig.dreams.first?.id
        let divination = TarotService.divination(from: reading, relatedDreamID: relatedDreamID)
        modelContext.insert(divination)
        try? modelContext.save()

        let tarotSummary = Self.tarotContextText(reading: reading)
        let combinedPrompt = """
        \(pendingTarotConfig.prompt)

        已完成正式塔罗抽牌，请结合以下结果解读：
        \(tarotSummary)
        """

        showTarotSheet = false
        self.pendingTarotConfig = nil
        inputText = ""
        await sendMessage(
            displayContent: pendingTarotConfig.prompt,
            agentInput: combinedPrompt,
            dreams: pendingTarotConfig.dreams,
            divinations: [divination] + divinations
        )
    }

    func cancelTarotSetup() {
        showTarotSheet = false
        pendingTarotConfig = nil
    }

    private func sendMessage(
        displayContent: String,
        agentInput: String,
        dreams: [Dream],
        divinations: [Divination]
    ) async {
        let trimmedDisplay = displayContent.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAgentInput = agentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDisplay.isEmpty, !trimmedAgentInput.isEmpty, !isSending else { return }

        if inputText.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedDisplay {
            inputText = ""
        }
        messages.append(Message(isUser: true, content: trimmedDisplay, expertBadges: [], references: [], executionTrace: [], toolTrace: []))

        isSending = true
        defer { isSending = false }

        let response = await AgentOrchestrator.shared.respond(
            userInput: trimmedAgentInput,
            dreams: dreams,
            divinations: divinations
        )
        messages.append(
            Message(
                isUser: false,
                content: response.content,
                expertBadges: response.consultedExperts,
                references: response.references,
                executionTrace: response.executionTrace,
                toolTrace: response.toolTrace
            )
        )
    }

    private static func tarotContextText(reading: TarotService.TarotReading) -> String {
        let cards = reading.cards.map {
            "\($0.position)：\($0.card.nameChinese)\($0.isReversed ? "逆位" : "正位")，含义为\($0.isReversed ? $0.card.reversedMeaning : $0.card.meaning)"
        }
        .joined(separator: "；")

        return "牌阵：\(reading.spread.rawValue)。牌面：\(cards)。正式解读：\(reading.interpretation)"
    }
}

private struct AgentTarotSetupSheet: View {
    let isLoading: Bool
    let onConfirm: (TarotService.SpreadType, TarotService.DeckType) -> Void
    let onCancel: () -> Void

    @State private var selectedSpread: TarotService.SpreadType = .threeCard
    @State private var selectedDeckType: TarotService.DeckType = .full

    var body: some View {
        ZStack {
            InterpreterBackground()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: DreamSpacing.lg) {
                Text("先完成正式抽牌")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundStyle(.white)

                Text("这次问题需要抽牌辅助。选择牌阵和牌组后，应用会使用现有塔罗流程完成正式抽牌与解读，再交给代理继续回答。")
                    .font(.system(size: 13, weight: .light, design: .serif))
                    .foregroundStyle(.white.opacity(0.72))
                    .lineSpacing(5)

                VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                    Text("牌组类型")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))

                    HStack(spacing: DreamSpacing.sm) {
                        deckTypeCard(.majorOnly, title: "大阿尔卡纳", subtitle: "22张")
                        deckTypeCard(.full, title: "完整牌组", subtitle: "78张")
                    }
                }

                VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                    Text("牌阵类型")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))

                    HStack(spacing: DreamSpacing.sm) {
                        spreadCard(.single, title: "单张", subtitle: "快速聚焦")
                        spreadCard(.threeCard, title: "三牌阵", subtitle: "过去 / 现在 / 未来")
                        spreadCard(.celtic, title: "十字", subtitle: "完整展开")
                    }
                }

                Spacer()

                HStack(spacing: DreamSpacing.sm) {
                    Button(action: onCancel) {
                        Text("取消")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DreamSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading)

                    Button {
                        onConfirm(selectedSpread, selectedDeckType)
                    } label: {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isLoading ? "正在抽牌..." : "开始正式抽牌")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DreamSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.auroraLavender.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.auroraLavender.opacity(0.35), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading)
                }
            }
            .padding(DreamSpacing.lg)
        }
    }

    private func deckTypeCard(_ deckType: TarotService.DeckType, title: String, subtitle: String) -> some View {
        let isSelected = selectedDeckType == deckType
        return Button {
            selectedDeckType = deckType
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? Color.auroraLavender : .white.opacity(0.78))
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DreamSpacing.sm)
            .background(selectionBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }

    private func spreadCard(_ spread: TarotService.SpreadType, title: String, subtitle: String) -> some View {
        let isSelected = selectedSpread == spread
        return Button {
            selectedSpread = spread
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? Color.auroraLavender : .white.opacity(0.78))
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DreamSpacing.sm)
            .background(selectionBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }

    private func selectionBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.auroraLavender.opacity(0.15) : Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.auroraLavender.opacity(0.35) : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
    }
}

private struct AgentMessageCard: View {
    let message: AgentConversationViewModel.Message

    var body: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
            HStack {
                Image(systemName: message.isUser ? "person.circle.fill" : "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(message.isUser ? Color.auroraLavender : .white.opacity(0.75))

                Text(message.isUser ? "你" : "梦境代理")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.82))

                Spacer()

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.38))
            }

            Text(message.content)
                .font(.system(size: 14, weight: .light, design: message.isUser ? .default : .serif))
                .foregroundStyle(.white.opacity(0.92))
                .lineSpacing(6)

            if !message.expertBadges.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DreamSpacing.sm) {
                        ForEach(message.expertBadges, id: \.self) { badge in
                            Text(badge)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.72))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.08))
                                )
                        }
                    }
                }
            }

            if !message.executionTrace.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("本次调用")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.58))

                    ForEach(message.executionTrace) { record in
                        HStack(spacing: 8) {
                            Text(record.selectedSkillName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))

                            Text(record.capability.rawValue)
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.42))

                            Spacer()

                            Text("score \(record.score)")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.auroraLavender.opacity(0.88))
                        }
                    }
                }
            }

            if !message.toolTrace.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("本次工具")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.58))

                    ForEach(message.toolTrace) { record in
                        HStack(spacing: 8) {
                            Text(record.toolName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))

                            Text(record.capability.rawValue)
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.42))

                            Spacer()

                            Text("score \(record.score)")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.auroraLavender.opacity(0.88))
                        }
                    }
                }
            }

            if !message.references.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(message.references.prefix(3)) { reference in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(reference.badge)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.auroraLavender)
                                Text(reference.title)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.82))
                            }

                            Text(reference.excerpt)
                                .font(.system(size: 12, weight: .light))
                                .foregroundStyle(.white.opacity(0.56))
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 2)
                    }
                }
            }
        }
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(message.isUser ? Color.auroraLavender.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(message.isUser ? Color.auroraLavender.opacity(0.24) : Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

private struct AgentInputBar: View {
    @Binding var inputText: String
    let isSending: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: DreamSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 16))
                .foregroundStyle(Color.auroraLavender.opacity(0.85))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )

            TextField("问问梦境代理...", text: $inputText, axis: .vertical)
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
                .disabled(isSending)

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.white.opacity(0.3)
                            : Color.auroraLavender
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
        .padding(.horizontal, DreamSpacing.md)
        .padding(.vertical, DreamSpacing.md)
    }
}
