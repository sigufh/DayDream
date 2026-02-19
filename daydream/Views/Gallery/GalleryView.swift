import SwiftUI
import SwiftData

struct GalleryView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()

            if dreams.isEmpty {
                GalleryEmptyStateView()
            } else {
                ScrollView {
                    WaterfallLayout(columns: DreamSpacing.gridColumns, spacing: DreamSpacing.gridSpacing) {
                        ForEach(dreams) { dream in
                            DreamCardView(dream: dream)
                                .onTapGesture {
                                    router.galleryPath.append(dream)
                                }
                        }
                    }
                    .padding(.horizontal, DreamSpacing.gridHorizontalPadding)
                    .padding(.top, DreamSpacing.md)
                    .padding(.bottom, 120) // 为光球留出空间
                }
            }
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
