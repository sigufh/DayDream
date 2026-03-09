import SwiftUI
import SwiftData

struct GalleryView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.createdAt, order: .reverse) private var allDreams: [Dream]
    @State private var showSettings = false
    @State private var searchText = ""
    @State private var selectedEmotion: DreamEmotion? = nil
    @State private var showFavoritesOnly = false

    var filteredDreams: [Dream] {
        var result = allDreams

        // 收藏筛选
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        // 情绪筛选
        if let emotion = selectedEmotion {
            result = result.filter { $0.emotion == emotion }
        }

        // 搜索筛选
        if !searchText.isEmpty {
            result = result.filter { dream in
                dream.transcript.localizedCaseInsensitiveContains(searchText) ||
                dream.poem.localizedCaseInsensitiveContains(searchText) ||
                dream.symbols.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        return result
    }

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // 搜索栏（始终显示）
                    SearchBar(text: $searchText)
                        .padding(.horizontal, DreamSpacing.md)
                        .padding(.top, DreamSpacing.sm)
                        .padding(.bottom, DreamSpacing.xs)

                    // 筛选器（始终显示）
                    FilterBar(
                        selectedEmotion: $selectedEmotion,
                        showFavoritesOnly: $showFavoritesOnly
                    )
                    .padding(.horizontal, DreamSpacing.md)
                    .padding(.bottom, DreamSpacing.sm)

                    // 内容区域
                    if allDreams.isEmpty {
                        GalleryEmptyStateView()
                            .padding(.top, 60)
                    } else if filteredDreams.isEmpty {
                        EmptySearchResultView()
                            .padding(.top, 60)
                    } else {
                        WaterfallLayout(columns: DreamSpacing.gridColumns, spacing: DreamSpacing.gridSpacing) {
                            ForEach(filteredDreams) { dream in
                                DreamCardView(dream: dream)
                                    .onTapGesture {
                                        router.galleryPath.append(dream)
                                    }
                            }
                        }
                        .padding(.horizontal, DreamSpacing.gridHorizontalPadding)
                        .padding(.top, DreamSpacing.sm)
                        .padding(.bottom, 120) // 为光球留出空间
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("梦境回廊")
                    .dreamHeadline()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.deepBlueGray)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct GalleryEmptyStateView: View {
    var body: some View {
        VStack(spacing: DreamSpacing.lg) {
            Image(systemName: "moon.zzz")
                .font(.system(size: 48))
                .foregroundStyle(Color.auroraLavender.opacity(0.5))

            VStack(spacing: DreamSpacing.sm) {
                Text("还没有梦境记录")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundStyle(Color.deepBlueGray)

                Text("长按下方光球，开始记录你的第一个梦")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.mistyBlue)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, DreamSpacing.xl)
    }
}
