import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    private let cards: [OnboardingCard] = [
        OnboardingCard(
            icon: "moon.stars.fill",
            title: "记录你的梦境",
            titleEN: "Record Your Dreams",
            description: "用声音捕捉梦的碎片，让AI为你编织成诗意的画面",
            descriptionEN: "Capture dream fragments with your voice, let AI weave them into poetic imagery"
        ),
        OnboardingCard(
            icon: "waveform.circle.fill",
            title: "听云语",
            titleEN: "Cloud Whispers",
            description: "对着星辰诉说，光粒会随你的声音起舞",
            descriptionEN: "Speak to the stars, particles dance with your voice"
        ),
        OnboardingCard(
            icon: "photo.artframe",
            title: "浮光拓印",
            titleEN: "Light Imprint",
            description: "每个梦都是一幅独特的画，一首只属于你的诗",
            descriptionEN: "Every dream is a unique painting, a poem that belongs only to you"
        ),
        OnboardingCard(
            icon: "sparkles",
            title: "开始梦旅",
            titleEN: "Begin Your Journey",
            description: "打开浮光梦境，让每一个夜晚都值得记忆",
            descriptionEN: "Open DayDream, make every night worth remembering"
        ),
    ]

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()

            VStack {
                TabView(selection: $currentPage) {
                    ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                        OnboardingCardView(card: card)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                // Bottom buttons
                HStack {
                    if currentPage < cards.count - 1 {
                        Button("跳过") {
                            appState.finishOnboarding()
                        }
                        .foregroundStyle(Color.mistyBlue)
                        .dreamCaption()

                        Spacer()

                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("下一步")
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(Color.auroraLavender)
                        }
                    } else {
                        Spacer()
                        Button {
                            appState.finishOnboarding()
                        } label: {
                            Text("进入梦境")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, DreamSpacing.xl)
                                .padding(.vertical, DreamSpacing.md)
                                .background(
                                    Capsule()
                                        .fill(Color.auroraLavender)
                                )
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, DreamSpacing.lg)
                .padding(.bottom, DreamSpacing.xl)
            }
        }
    }
}

struct OnboardingCard: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let titleEN: String
    let description: String
    let descriptionEN: String
}
