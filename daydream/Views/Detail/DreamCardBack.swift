import SwiftUI

struct DreamCardBack: View {
    let dream: Dream

    var body: some View {
        ZStack {
            Color.ivoryGray

            VStack(spacing: DreamSpacing.xl) {
                Spacer()

                // Reflection question
                if let question = dream.reflectionQuestion {
                    Text(question)
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundStyle(Color.deepBlueGray)
                        .tracking(3)
                        .lineSpacing(12)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DreamSpacing.xl)
                }

                // Divider
                Rectangle()
                    .fill(Color.auroraLavender.opacity(0.4))
                    .frame(width: 40, height: 1)

                // Emotion & symbols
                VStack(spacing: DreamSpacing.sm) {
                    Text(dream.emotion.displayName)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(dream.emotion.primaryColor)
                        .tracking(2)

                    if !dream.symbols.isEmpty {
                        HStack(spacing: DreamSpacing.sm) {
                            ForEach(dream.symbols, id: \.self) { symbol in
                                Text(symbol)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.mistyBlue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.linen.opacity(0.5))
                                    )
                            }
                        }
                    }
                }

                Spacer()

                // World name
                if let worldName = dream.worldName {
                    Text(worldName)
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(Color.mistyBlue)
                        .tracking(4)
                        .padding(.bottom, DreamSpacing.lg)
                }
            }

            // Tap hint
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mistyBlue.opacity(0.4))
                        .padding(DreamSpacing.md)
                }
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DreamSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
    }
}
