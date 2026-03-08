import SwiftUI
import SwiftData

struct HexagramView: View {
    @Bindable var chatViewModel: InterpreterChatViewModel
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @Query(sort: \Divination.date, order: .reverse) private var divinations: [Divination]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = HexagramViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: DreamSpacing.xl) {
                    Spacer()
                        .frame(height: DreamSpacing.md)

                    // 摇一摇提示或占卜结果
                    if let divination = viewModel.currentDivination,
                       let hexagramName = divination.hexagramName,
                       let hexagramMeaning = divination.hexagramMeaning {
                        // 显示占卜结果
                        divinationResult(divination, hexagramName: hexagramName, hexagramMeaning: hexagramMeaning)
                    } else {
                        // 摇一摇提示
                        shakePrompt
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

            // Shake feedback overlay
            if viewModel.shakeDetected {
                Color.white.opacity(0.15)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.shakeDetected)
            }

            // Falling leaves overlay (六爻占卜动画)
            if viewModel.isLeavesFalling {
                FallingLeavesOverlay { yaos in
                    Task {
                        await viewModel.completeDivination(
                            yaos: yaos,
                            dreams: dreams,
                            modelContext: modelContext
                        )
                    }
                }
                .allowsHitTesting(false)
            }

            // Shake detector (invisible)
            ShakeDetector {
                viewModel.triggerDivination()
            }
            .frame(width: 0, height: 0)

            // 固定底部输入框
            VStack {
                Spacer()
                ChatInputBar(viewModel: chatViewModel)
            }
        }
        .sheet(isPresented: $viewModel.showResult) {
            if let result = viewModel.latestResult {
                DivinationResultSheet(divination: result) {
                    viewModel.showResult = false
                }
            }
        }
    }

    private var shakePrompt: some View {
        VStack(spacing: DreamSpacing.md) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.auroraLavender.opacity(0.6))
                .scaleEffect(viewModel.shakeDetected ? 1.3 : 1.0)
                .rotationEffect(.degrees(viewModel.shakeDetected ? 360 : 0))
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.shakeDetected)

            Text("摇一摇，落叶问签")
                .font(.system(size: 14, weight: .light, design: .serif))
                .foregroundStyle(.white.opacity(0.7))
                .scaleEffect(viewModel.shakeDetected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.shakeDetected)

            Text("轻轻摇动手机，六爻卜卦，探知天机")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, DreamSpacing.lg)
    }

    private func divinationResult(_ divination: Divination, hexagramName: String, hexagramMeaning: String) -> some View {
        VStack(alignment: .leading, spacing: DreamSpacing.md) {
            // 本卦名称
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("【\(hexagramName)】卦")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundStyle(.white)

                    Text(hexagramMeaning)
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                // 如果有变卦，显示箭头和变卦
                if let transformedName = divination.transformedHexagramName,
                   let transformedMeaning = divination.transformedHexagramMeaning {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("【\(transformedName)】")
                            .font(.system(size: 15, weight: .medium, design: .serif))
                            .foregroundStyle(Color.auroraLavender)

                        Text(transformedMeaning)
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }

            // 卦象图形
            VStack(spacing: 4) {
                ForEach(divination.leaves.indices.reversed(), id: \.self) { index in
                    if let yaoType = DivinationService.YaoType(rawValue: divination.leaves[index]) {
                        HStack(spacing: 4) {
                            Text(yaoType.symbol)
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundStyle(
                                    yaoType.isMoving ?
                                    Color.auroraLavender : .white.opacity(0.8)
                                )

                            if yaoType.isMoving {
                                Text("动")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.auroraLavender.opacity(0.8))
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DreamSpacing.sm)

            // 解读文字
            Text(divination.interpretation)
                .font(.system(size: 14, weight: .light, design: .serif))
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)

            // 占卜时间
            Text(divination.date.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.4))
                .frame(maxWidth: .infinity, alignment: .trailing)
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

@Observable
final class HexagramViewModel {
    var isLeavesFalling = false
    var isInterpreting = false
    var latestResult: Divination?
    var showResult = false
    var shakeDetected = false
    var currentDivination: Divination?

    func triggerDivination() {
        guard !isLeavesFalling && !isInterpreting else { return }

        // 清除之前的结果
        currentDivination = nil

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()

        // 视觉反馈动画
        shakeDetected = true

        // 延迟启动落叶动画，让用户看到摇动反馈
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
            shakeDetected = false
            isLeavesFalling = true
        }
    }

    func completeDivination(yaos: [DivinationService.YaoType], dreams: [Dream], modelContext: ModelContext) async {
        isLeavesFalling = false
        isInterpreting = true
        defer { isInterpreting = false }

        // 查询本卦
        let hexagram = DivinationService.lookupHexagram(yaos: yaos)

        // 获取变卦（如有）
        let transformedHex = hexagram.transformedHexagram
        let movingYaos = hexagram.movingYaos

        // 获取解读
        let interpretation = await DivinationService.interpretHexagram(hexagram: hexagram, dreams: dreams)

        let yaoNames = yaos.map { $0.rawValue }
        let relatedDreamID = dreams.first?.id

        let divination = Divination(
            leaves: yaoNames,
            hexagramName: hexagram.name,
            hexagramMeaning: hexagram.meaning,
            transformedHexagramName: transformedHex?.name,
            transformedHexagramMeaning: transformedHex?.meaning,
            movingYaoIndices: movingYaos,
            interpretation: interpretation,
            relatedDreamID: relatedDreamID
        )

        modelContext.insert(divination)
        try? modelContext.save()

        latestResult = divination
        currentDivination = divination
        showResult = true
    }
}
