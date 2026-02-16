import SwiftUI
import SwiftData

struct CurationView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @State private var imageOffset: CGSize = .zero
    @State private var imageScale: CGFloat = 1.0
    @State private var poemPosition: CGSize = .zero
    @State private var poemScale: CGFloat = 1.0
    @State private var showDateWatermark = true
    @State private var showLocationWatermark = true
    @State private var showWeatherWatermark = true
    @State private var isSaving = false
    @State private var showSaveSuccess = false

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        router.dismissToGallery()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .light))
                            .foregroundStyle(Color.deepBlueGray)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("光景策展")
                        .font(.system(size: 16, weight: .light, design: .serif))
                        .foregroundStyle(Color.deepBlueGray)
                        .tracking(2)

                    Spacer()

                    // Save button
                    Button {
                        Task { await saveDream() }
                    } label: {
                        Text("保存")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.auroraLavender)
                            .frame(width: 44, height: 44)
                    }
                    .disabled(isSaving)
                }
                .padding(.horizontal, DreamSpacing.md)

                // Canvas area
                ZStack {
                    // Image
                    ImageEditorView(
                        imageData: router.processedImageData,
                        imageOffset: $imageOffset,
                        imageScale: $imageScale
                    )

                    // Text overlay
                    TextOverlayEditor(
                        text: .constant(router.processedPoem),
                        position: $poemPosition,
                        textScale: $poemScale
                    )
                }
                .padding(DreamSpacing.md)

                Spacer()

                // Watermark toggles
                VStack(spacing: DreamSpacing.md) {
                    Text("水印设置")
                        .dreamCaption()

                    HStack(spacing: DreamSpacing.lg) {
                        WatermarkToggle(
                            icon: "calendar",
                            label: "日期",
                            isOn: $showDateWatermark
                        )
                        WatermarkToggle(
                            icon: "location.fill",
                            label: "地点",
                            isOn: $showLocationWatermark
                        )
                        WatermarkToggle(
                            icon: "cloud.fill",
                            label: "天气",
                            isOn: $showWeatherWatermark
                        )
                    }
                }
                .padding(.horizontal, DreamSpacing.lg)

                Spacer()
                    .frame(height: DreamSpacing.md)

                // Bottom actions
                HStack(spacing: DreamSpacing.xl) {
                    Button {
                        Task { await saveToPhotos() }
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

                    Button {
                        Task { await saveDream() }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                            Text("完成")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(Color.auroraLavender)
                    }
                }
                .padding(.bottom, DreamSpacing.xl)
            }

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
                        .padding(.bottom, DreamSpacing.xxl * 2)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSaveSuccess)
    }

    private func saveDream() async {
        isSaving = true
        defer { isSaving = false }

        let dream = Dream(
            transcript: router.capturedTranscript,
            poem: router.processedPoem,
            emotion: router.capturedEmotion,
            imageData: router.processedImageData,
            reflectionQuestion: router.processedReflection
        )

        modelContext.insert(dream)
        try? modelContext.save()

        showSaveSuccess = true
        try? await Task.sleep(for: .seconds(1.0))
        showSaveSuccess = false

        router.finishCuration()
    }

    private func saveToPhotos() async {
        guard let imageData = router.processedImageData,
              let uiImage = UIImage(data: imageData) else { return }
        let saved = await PhotoAlbumManager.saveImage(uiImage)
        if saved {
            showSaveSuccess = true
            try? await Task.sleep(for: .seconds(1.0))
            showSaveSuccess = false
        }
    }

    private func shareImage() {
        guard let imageData = router.processedImageData,
              let uiImage = UIImage(data: imageData) else { return }
        let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct WatermarkToggle: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isOn ? Color.auroraLavender : Color.linen)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(isOn ? Color.deepBlueGray : Color.mistyBlue)
            }
            .frame(width: 50)
        }
    }
}
