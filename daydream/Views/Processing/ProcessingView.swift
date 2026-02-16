import SwiftUI

struct ProcessingView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @State private var aiService = AIService()
    @State private var locationManager = LocationManager()
    @State private var weatherService = WeatherService()
    @State private var generatedContent: AIService.DreamContent?
    @State private var isRevealed = false
    @State private var showContent = false

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
                VStack(spacing: DreamSpacing.lg) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)

                    Text("浮光拓印中…")
                        .font(.system(size: 16, weight: .light, design: .serif))
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(2)
                }
            }

            // Close button
            VStack {
                HStack {
                    Button {
                        router.dismissToGallery()
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
        .task {
            await generateContent()
        }
    }

    private func generateContent() async {
        // Fetch location & weather in parallel
        async let locationTask: () = fetchLocation()
        async let weatherTask: () = weatherService.fetchWeather(for: locationManager.currentLocation)

        let content = await aiService.generateDreamContent(
            transcript: router.capturedTranscript,
            emotion: router.capturedEmotion,
            weather: weatherService.weatherDescription,
            location: locationManager.locationName
        )

        _ = await (locationTask, weatherTask)

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
        Task {
            await generateContent()
        }
    }

    private func confirmAndProceed() {
        guard let content = generatedContent else { return }
        router.finishProcessing(
            imageData: content.imageData,
            poem: content.poem,
            reflection: content.reflectionQuestion
        )
    }
}
