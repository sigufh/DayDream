import SwiftUI

struct DreamDetailView: View {
    let dream: Dream
    @State private var isFlipped = false
    @State private var showSaveSuccess = false
    @State private var showPermissionAlert = false

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()

            VStack(spacing: 0) {
                // 卡片内容区
                GeometryReader { geo in
                    let cardWidth = geo.size.width - DreamSpacing.xl * 2
                    let cardHeight = cardWidth / DreamSpacing.detailCardAspectRatio

                    ZStack {
                        // Back face
                        DreamCardBack(dream: dream)
                            .frame(width: cardWidth, height: cardHeight)
                            .rotation3DEffect(
                                .degrees(isFlipped ? 0 : 180),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .opacity(isFlipped ? 1 : 0)

                        // Front face
                        DreamCardFront(dream: dream)
                            .frame(width: cardWidth, height: cardHeight)
                            .rotation3DEffect(
                                .degrees(isFlipped ? -180 : 0),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .opacity(isFlipped ? 0 : 1)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: DreamSpacing.flipDuration, dampingFraction: 0.8)) {
                            isFlipped.toggle()
                        }
                    }
                }

                // 底部操作按钮
                HStack(spacing: DreamSpacing.xl) {
                    Button {
                        Task { @MainActor in
                            await saveToPhotos()
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 20))
                            Text("存入相册")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(Color.deepBlueGray)
                    }

                    Button {
                        shareImage()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                            Text("分享")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(Color.deepBlueGray)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DreamSpacing.lg)
                .background(Color.pearlWhite)
            }

            // 成功提示
            if showSaveSuccess {
                VStack {
                    Spacer()
                    Text("已保存")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, DreamSpacing.lg)
                        .padding(.vertical, DreamSpacing.sm)
                        .background(Capsule().fill(Color.auroraLavender))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .alert("需要相册权限", isPresented: $showPermissionAlert) {
            Button("确定", role: .cancel) {}
        }
        .animation(.easeInOut(duration: 0.3), value: showSaveSuccess)
    }

    @MainActor
    private func renderCard() -> UIImage? {
        // 使用与策展室相同的格式
        let card = PolaroidCardView(
            imageData: dream.imageData,
            poem: dream.poem,
            emotion: dream.emotion,
            date: dream.createdAt,
            weather: dream.weatherDescription,
            showDate: true,
            showWeather: dream.weatherDescription != nil
        )
        return card.render()
    }

    private func saveToPhotos() async {
        let renderedImage = await MainActor.run {
            renderCard()
        }

        guard let renderedImage else { return }

        let result = await PhotoAlbumManager.saveImage(renderedImage)

        await MainActor.run {
            switch result {
            case .success:
                showSaveSuccess = true
            case .noPermission:
                showPermissionAlert = true
            case .failure:
                break
            }
        }

        try? await Task.sleep(for: .seconds(1.0))

        await MainActor.run {
            showSaveSuccess = false
        }
    }

    private func shareImage() {
        Task { @MainActor in
            guard let renderedImage = renderCard() else { return }
            let activityVC = UIActivityViewController(activityItems: [renderedImage], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }
}
