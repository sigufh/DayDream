import SwiftUI

struct ProcessingView: View {
    let onComplete: () -> Void
    let onDismiss: () -> Void

    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @State private var aiService = AIService()
    @State private var locationManager = LocationManager()
    @State private var weatherService = WeatherService()
    @State private var generatedContent: AIService.DreamContent?
    @State private var isRevealed = false
    @State private var showContent = false
    @State private var generationTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Color.twilightCyanBlue.ignoresSafeArea()

            if let content = generatedContent, showContent {
                ScrollView {
                    VStack(spacing: DreamSpacing.xl) {
                        Spacer()
                            .frame(height: DreamSpacing.xxl)

                        DevelopingPhotoEffect(
                            imageData: content.imageData,
                            poem: content.poem,
                            emotion: router.capturedEmotion,
                            isRevealed: $isRevealed
                        )

                        // Location & weather watermarks
                        HStack {
                            if let location = locationManager.locationName {
                                Label(location, systemImage: "location.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            Spacer()
                            if let weather = weatherService.weatherDescription {
                                Label(weather, systemImage: "cloud.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, DreamSpacing.xl)

                        if aiService.lastError != nil {
                            Text("离线模式 · 使用预设内容")
                                .font(.system(size: 11, weight: .light))
                                .foregroundStyle(.white.opacity(0.35))
                        }

                        Spacer()
                            .frame(height: DreamSpacing.lg)

                        // Action buttons
                        HStack(spacing: DreamSpacing.xl) {
                            Button {
                                regenerate()
                            } label: {
                                Text("重新洗相")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.horizontal, DreamSpacing.lg)
                                    .padding(.vertical, DreamSpacing.md)
                                    .background(
                                        Capsule()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            }

                            Button {
                                confirmAndProceed()
                            } label: {
                                Text("确认")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, DreamSpacing.xl)
                                    .padding(.vertical, DreamSpacing.md)
                                    .background(
                                        Capsule()
                                            .fill(Color.auroraLavender)
                                    )
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, DreamSpacing.md)
                }
            } else {
                // Loading state
                DreamLoadingView(emotion: router.capturedEmotion)

                if aiService.lastError != nil {
                    VStack {
                        Spacer()
                        Text("使用离线模式")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.white.opacity(0.35))
                            .padding(.bottom, DreamSpacing.xxl)
                    }
                }
            }

            // Close button
            VStack {
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .light))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, DreamSpacing.md)
                Spacer()
            }
        }
        .onAppear {
            guard generationTask == nil else { return }
            generationTask = Task { await generateContent() }
        }
        .onDisappear {
            // Don't cancel — let the API call finish even if view briefly disappears
        }
    }

    private func generateContent() async {
        // 1. Fetch location first
        await fetchLocation()

        // 2. Fetch weather using the resolved location
        await weatherService.fetchWeather(for: locationManager.currentLocation)

        // 3. Now call AI with all context available
        let content = await aiService.generateDreamContent(
            transcript: router.capturedTranscript,
            emotion: router.capturedEmotion,
            weather: weatherService.weatherDescription,
            location: locationManager.locationName
        )

        // 如果 AI 检测到了情绪，更新 router
        if let detectedEmotion = content.detectedEmotion {
            router.capturedEmotion = detectedEmotion
        }

        generatedContent = content
        showContent = true

        // Trigger reveal animation shortly after
        try? await Task.sleep(for: .seconds(0.3))
        isRevealed = true
    }

    private func fetchLocation() async {
        if let location = await locationManager.requestLocation() {
            locationManager.locationName = await locationManager.reverseGeocode(location: location)
        }
    }

    private func regenerate() {
        generatedContent = nil
        showContent = false
        isRevealed = false
        generationTask?.cancel()
        generationTask = Task { await generateContent() }
    }

    private func confirmAndProceed() {
        guard let content = generatedContent else { return }

        // 保存处理结果到 router
        router.processedImageData = content.imageData
        router.processedPoem = content.poem
        router.processedReflection = content.reflectionQuestion
        router.processedWorldName = content.worldName
        router.processedSymbols = content.symbols
        router.processedLocation = locationManager.locationName
        router.processedWeather = weatherService.weatherDescription

        // 触发完成动画（由 TransitionManager 控制页面切换）
        onComplete()
    }
}
