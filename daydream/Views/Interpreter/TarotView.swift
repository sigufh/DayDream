import SwiftUI
import SwiftData

struct TarotView: View {
    @Bindable var chatViewModel: InterpreterChatViewModel
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TarotViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: DreamSpacing.xl) {
                    Spacer()
                        .frame(height: DreamSpacing.md)

                    // 抽牌提示或占卜结果
                    if let reading = viewModel.currentReading {
                        // 显示塔罗结果
                        tarotResult(reading)
                    } else {
                        // 抽牌提示
                        tarotPrompt
                    }

                    // AI 聊天记录
                    ChatMessagesList(viewModel: chatViewModel)

                    Spacer()
                        .frame(height: 100)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            // Loading indicator
            if viewModel.isInterpreting {
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(.white.opacity(0.6))
                        .padding(.bottom, DreamSpacing.xxl)
                }
            }

            // 抽牌动画
            if viewModel.isDrawing {
                tarotDrawingOverlay
            }

            // 固定底部输入框
            VStack {
                Spacer()
                ChatInputBar(viewModel: chatViewModel)
            }
        }
    }

    private var tarotPrompt: some View {
        VStack(spacing: DreamSpacing.lg) {
            // 牌组类型选择
            VStack(spacing: DreamSpacing.sm) {
                Text("牌组类型")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.6))

                HStack(spacing: DreamSpacing.sm) {
                    deckTypeButton(.majorOnly, title: "大阿尔卡纳", subtitle: "22张")
                    deckTypeButton(.full, title: "完整牌组", subtitle: "78张")
                }
            }

            // 牌阵选择
            VStack(spacing: DreamSpacing.sm) {
                Text("选择牌阵")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.6))

                HStack(spacing: DreamSpacing.md) {
                    spreadButton(.single, icon: "square", title: "单张")
                    spreadButton(.threeCard, icon: "square.grid.3x1", title: "三牌阵")
                }
            }

            // 抽牌按钮
            Button {
                viewModel.startDrawing()
            } label: {
                VStack(spacing: DreamSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.auroraLavender.opacity(0.8))

                    Text("开始抽牌")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DreamSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.auroraLavender.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, DreamSpacing.md)

            Text("静心凝神，心中默念问题")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DreamSpacing.md)
    }

    private func deckTypeButton(_ deckType: TarotService.DeckType, title: String, subtitle: String) -> some View {
        Button {
            viewModel.selectedDeckType = deckType
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(
                        viewModel.selectedDeckType == deckType ?
                        Color.auroraLavender : .white.opacity(0.7)
                    )

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DreamSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        viewModel.selectedDeckType == deckType ?
                        Color.auroraLavender.opacity(0.15) : Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                viewModel.selectedDeckType == deckType ?
                                Color.auroraLavender.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
    }

    private func spreadButton(_ spread: TarotService.SpreadType, icon: String, title: String) -> some View {
        Button {
            viewModel.selectedSpread = spread
        } label: {
            VStack(spacing: DreamSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(
                        viewModel.selectedSpread == spread ?
                        Color.auroraLavender : .white.opacity(0.5)
                    )
                    .frame(height: 30)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(
                        viewModel.selectedSpread == spread ?
                        Color.auroraLavender : .white.opacity(0.5)
                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        viewModel.selectedSpread == spread ?
                        Color.auroraLavender.opacity(0.1) : Color.white.opacity(0.03)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                viewModel.selectedSpread == spread ?
                                Color.auroraLavender.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
    }

    private var tarotDrawingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("正在抽牌...")
                    .font(.system(size: 20, weight: .light, design: .serif))
                    .foregroundStyle(.white)

                // 翻转的牌背动画
                ForEach(0..<viewModel.drawingCards.count, id: \.self) { index in
                    if index < viewModel.currentDrawingIndex {
                        TarotCardView(card: viewModel.drawingCards[index].card, isReversed: viewModel.drawingCards[index].isReversed)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                if viewModel.currentDrawingIndex < viewModel.drawingCards.count {
                    FlippingCard()
                        .frame(width: 100, height: 150)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.performDrawing(dreams: dreams, modelContext: modelContext)
            }
        }
    }

    private func tarotResult(_ reading: TarotService.TarotReading) -> some View {
        VStack(alignment: .leading, spacing: DreamSpacing.md) {
            // 牌阵标题
            Text(reading.spread.rawValue)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.7))

            // 抽到的牌
            HStack(spacing: DreamSpacing.md) {
                ForEach(reading.cards.indices, id: \.self) { index in
                    TarotCardView(card: reading.cards[index].card, isReversed: reading.cards[index].isReversed)
                }
            }
            .frame(maxWidth: .infinity)

            // 解读文字
            Text(reading.interpretation)
                .font(.system(size: 14, weight: .light, design: .serif))
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .padding(.top, DreamSpacing.sm)
        }
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, DreamSpacing.md)
        .transition(.opacity.combined(with: .scale))
    }
}

// 塔罗牌卡片视图
private struct TarotCardView: View {
    let card: TarotService.TarotCard
    let isReversed: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4A148C"), Color(hex: "7B1FA2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 120)

                VStack(spacing: 4) {
                    Image(systemName: card.imageSymbol)
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.9))
                        .rotationEffect(.degrees(isReversed ? 180 : 0))

                    Text(card.nameChinese)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white)
                }
            }

            Text(isReversed ? "逆位" : "正位")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// 翻转动画
private struct FlippingCard: View {
    @State private var rotation: Double = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.auroraLavender.opacity(0.3))
            .overlay(
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.6))
            )
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

@Observable
final class TarotViewModel {
    var selectedSpread: TarotService.SpreadType = .threeCard
    var selectedDeckType: TarotService.DeckType = .full
    var isDrawing = false
    var isInterpreting = false
    var currentReading: TarotService.TarotReading?
    var drawingCards: [TarotService.TarotReading.DrawnCard] = []
    var currentDrawingIndex = 0

    func startDrawing() {
        guard !isDrawing else { return }
        currentReading = nil
        isDrawing = true

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func performDrawing(dreams: [Dream], modelContext: ModelContext) async {
        let cardCount = TarotService.cardCount(for: selectedSpread)
        drawingCards = TarotService.drawCards(count: cardCount, deckType: selectedDeckType)
        currentDrawingIndex = 0

        // 逐张显示
        for index in drawingCards.indices {
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8秒
            currentDrawingIndex = index + 1
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
        isDrawing = false
        isInterpreting = true

        let finalReading = await TarotService.finalizeReading(
            cards: drawingCards,
            spread: selectedSpread,
            dreams: dreams
        )
        let divination = TarotService.divination(from: finalReading)
        modelContext.insert(divination)
        try? modelContext.save()

        await MainActor.run {
            isInterpreting = false
            currentReading = finalReading
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
