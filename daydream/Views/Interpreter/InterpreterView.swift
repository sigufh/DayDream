import SwiftUI
import SwiftData

struct InterpreterView: View {
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @Query(sort: \Divination.date, order: .reverse) private var divinations: [Divination]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = InterpreterViewModel()

    var body: some View {
        ZStack {
            InterpreterBackground()

            if dreams.isEmpty {
                InterpreterEmptyStateView()
            } else {
                ScrollView {
                    VStack(spacing: DreamSpacing.xl) {
                        Spacer()
                            .frame(height: DreamSpacing.md)

                        // Header
                        VStack(spacing: DreamSpacing.sm) {
                            Text("说书人")
                                .font(.system(size: 24, weight: .light, design: .serif))
                                .foregroundStyle(.white)
                                .tracking(4)

                            Text("解梦问签，叶落知秋")
                                .font(.system(size: 13, weight: .light))
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        // Zhou Gong interpretation card for latest dream
                        if let latestDream = dreams.first, !viewModel.todayInterpretation.isEmpty {
                            VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                                Text("今日解梦")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(.horizontal, DreamSpacing.md)

                                ZhouGongInterpretationCard(
                                    dream: latestDream,
                                    interpretation: viewModel.todayInterpretation
                                )
                            }
                            .padding(.horizontal, DreamSpacing.md)
                        }

                        // Shake prompt
                        VStack(spacing: DreamSpacing.md) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.auroraLavender.opacity(0.6))

                            Text("摇一摇，落叶问签")
                                .font(.system(size: 14, weight: .light, design: .serif))
                                .foregroundStyle(.white.opacity(0.7))

                            Text("轻轻摇动手机，三片叶子将为你指引方向")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, DreamSpacing.lg)

                        // Word cloud
                        if !divinations.isEmpty || !dreams.isEmpty {
                            VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                                Text("意象云图")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(.horizontal, DreamSpacing.md)

                                WordCloudView(divinations: divinations, dreams: dreams)
                                    .padding(.horizontal, DreamSpacing.md)
                            }
                        }

                        // Divination history
                        if !divinations.isEmpty {
                            VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                                Text("问签记录")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(.horizontal, DreamSpacing.md)

                                DivinationHistoryList(divinations: divinations)
                                    .padding(.horizontal, DreamSpacing.md)
                            }
                        }

                        Spacer()
                            .frame(height: DreamSpacing.xxl)
                    }
                }
            }

            // Falling leaves overlay
            if viewModel.isLeavesFalling {
                FallingLeavesOverlay { leaves in
                    viewModel.completeDivination(
                        leaves: leaves,
                        dreams: dreams,
                        modelContext: modelContext
                    )
                }
                .allowsHitTesting(false)
            }

            // Shake detector (invisible)
            ShakeDetector {
                viewModel.triggerDivination()
            }
            .frame(width: 0, height: 0)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $viewModel.showResult) {
            if let result = viewModel.latestResult {
                DivinationResultSheet(divination: result) {
                    viewModel.showResult = false
                }
            }
        }
        .task {
            await viewModel.generateInterpretation(for: dreams.first)
        }
    }
}

private struct InterpreterEmptyStateView: View {
    var body: some View {
        VStack(spacing: DreamSpacing.lg) {
            Image(systemName: "moon.stars")
                .font(.system(size: 48))
                .foregroundStyle(Color.auroraLavender.opacity(0.5))

            VStack(spacing: DreamSpacing.sm) {
                Text("尚无梦境可解")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundStyle(.white)

                Text("先记录一个梦境，说书人才能为你解读")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, DreamSpacing.xl)
    }
}
