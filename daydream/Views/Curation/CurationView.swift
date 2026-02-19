import SwiftUI
import SwiftData

struct CurationView: View {
    let onDismiss: () -> Void

    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @State private var showDateWatermark = true
    @State private var showWeatherWatermark = true
    @State private var isSaving = false
    @State private var showSaveSuccess = false
    @State private var showPermissionAlert = false

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        onDismiss()
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
                        Task { @MainActor in
                            await saveDream()
                        }
                    } label: {
                        Text("保存")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.auroraLavender)
                            .frame(width: 44, height: 44)
                    }
                    .disabled(isSaving)
                }
                .padding(.horizontal, DreamSpacing.md)

                Spacer()

                // Polaroid card preview
                ScrollView {
                    VStack {
                        Spacer()
                            .frame(height: DreamSpacing.xl)

                        PolaroidCardView(
                            imageData: router.processedImageData,
                            poem: router.processedPoem,
                            emotion: router.capturedEmotion,
                            date: Date(),
                            weather: router.processedWeather,
                            showDate: showDateWatermark,
                            showWeather: showWeatherWatermark
                        )
                        .id(showDateWatermark)
                        .id(showWeatherWatermark)

                        Spacer()
                    }
                }

                Spacer()

                // Watermark toggles
                VStack(spacing: DreamSpacing.md) {
                    Text("水印设置")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Color.mistyBlue)

                    HStack(spacing: DreamSpacing.xl) {
                        WatermarkToggle(
                            icon: "calendar",
                            label: "日期",
                            isOn: $showDateWatermark
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

                    Button {
                        Task { @MainActor in
                            await saveDream()
                        }
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
        await MainActor.run {
            isSaving = true
        }

        // Create dream on main thread
        await MainActor.run {
            let dream = Dream(
                transcript: router.capturedTranscript,
                poem: router.processedPoem,
                emotion: router.capturedEmotion,
                imageData: router.processedImageData,
                locationName: router.processedLocation,
                weatherDescription: router.processedWeather,
                reflectionQuestion: router.processedReflection,
                worldName: router.processedWorldName,
                symbols: router.processedSymbols
            )

            // Insert and save
            modelContext.insert(dream)

            do {
                try modelContext.save()
            } catch {
                print("Failed to save dream: \(error)")
            }

            isSaving = false
        }

        // Show success feedback
        await MainActor.run {
            showSaveSuccess = true
        }

        try? await Task.sleep(for: .seconds(1.0))

        await MainActor.run {
            showSaveSuccess = false
        }

        // Small delay before navigation to ensure save is fully committed
        try? await Task.sleep(for: .seconds(0.1))

        // Navigate away
        await MainActor.run {
            router.resetCaptureData()
            onDismiss()
        }
    }

    @MainActor
    private func renderCard() -> UIImage? {
        let card = PolaroidCardView(
            imageData: router.processedImageData,
            poem: router.processedPoem,
            emotion: router.capturedEmotion,
            date: Date(),
            weather: router.processedWeather,
            showDate: showDateWatermark,
            showWeather: showWeatherWatermark
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
