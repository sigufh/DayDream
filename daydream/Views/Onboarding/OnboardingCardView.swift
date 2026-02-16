import SwiftUI

struct OnboardingCardView: View {
    let card: OnboardingCard
    @State private var appeared = false

    var body: some View {
        VStack(spacing: DreamSpacing.xl) {
            Spacer()

            // Icon
            Image(systemName: card.icon)
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.auroraLavender, Color.midnightIndigo.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1.0 : 0)

            VStack(spacing: DreamSpacing.md) {
                Text(card.title)
                    .font(.system(size: 24, weight: .light, design: .serif))
                    .foregroundStyle(Color.deepBlueGray)
                    .tracking(2)

                Text(card.titleEN)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color.mistyBlue)
                    .tracking(1)
            }
            .opacity(appeared ? 1.0 : 0)

            TypewriterText(
                fullText: card.description,
                trigger: appeared
            )
            .dreamBody()
            .multilineTextAlignment(.center)
            .padding(.horizontal, DreamSpacing.xl)
            .frame(minHeight: 60)

            Text(card.descriptionEN)
                .dreamCaption()
                .multilineTextAlignment(.center)
                .padding(.horizontal, DreamSpacing.xl)
                .opacity(appeared ? 0.7 : 0)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}
