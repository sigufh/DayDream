import SwiftUI
import SwiftData

struct ZhouGongView: View {
    @Bindable var chatViewModel: InterpreterChatViewModel
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @State private var interpretation: String = ""
    @State private var isLoading = false
    @State private var loadedDreamId: UUID? = nil  // 记录已加载的梦境ID

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: DreamSpacing.xl) {
                    Spacer()
                        .frame(height: DreamSpacing.md)

                    if dreams.isEmpty {
                        emptyState
                    } else if let latestDream = dreams.first {
                        dreamCard(latestDream)
                    }

                    // AI 聊天记录
                    ChatMessagesList(viewModel: chatViewModel)

                    Spacer()
                        .frame(height: 100)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            // 固定底部输入框
            VStack {
                Spacer()
                ChatInputBar(viewModel: chatViewModel)
            }
        }
        .onChange(of: dreams.first?.id) { oldValue, newValue in
            // 只在梦境真正变化时加载
            if newValue != loadedDreamId {
                Task {
                    await loadInterpretation()
                }
            }
        }
        .onAppear {
            // 首次出现时，如果还没加载过当前梦境，才加载
            if let currentDreamId = dreams.first?.id, currentDreamId != loadedDreamId {
                Task {
                    await loadInterpretation()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DreamSpacing.lg) {
            Image(systemName: "moon.stars")
                .font(.system(size: 48))
                .foregroundStyle(Color.auroraLavender.opacity(0.5))

            VStack(spacing: DreamSpacing.sm) {
                Text("尚无梦境可解")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundStyle(.white)

                Text("先记录一个梦境，周公才能为你解读")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, DreamSpacing.xl)
    }

    private func dreamCard(_ dream: Dream) -> some View {
        VStack(alignment: .leading, spacing: DreamSpacing.md) {
            Text("今日解梦")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))

            ZhouGongInterpretationCard(dream: dream, interpretation: interpretation)
                .overlay {
                    if isLoading {
                        ProgressView()
                            .tint(.white.opacity(0.6))
                    }
                }
        }
        .padding(.horizontal, DreamSpacing.md)
    }

    private func loadInterpretation() async {
        guard let dream = dreams.first else {
            interpretation = ""
            loadedDreamId = nil
            return
        }

        // 如果已经加载过这个梦境，直接返回
        if dream.id == loadedDreamId {
            return
        }

        isLoading = true
        defer { isLoading = false }

        interpretation = await DivinationService.zhouGongInterpret(dream: dream)
        loadedDreamId = dream.id  // 记录已加载的梦境ID
    }
}
