import SwiftUI

struct ZhouGongInterpretationCard: View {
    let dream: Dream
    let interpretation: String

    var body: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.md) {
            // Header
            HStack {
                Circle()
                    .fill(dream.emotion.primaryColor)
                    .frame(width: 10, height: 10)

                Text(dream.emotion.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(dream.emotion.primaryColor)

                Spacer()

                Text(dream.createdAt.formatted(.dateTime.month().day()))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
            }

            // Interpretation text
            if !interpretation.isEmpty {
                Text(interpretation)
                    .font(.system(size: 15, weight: .light, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(8)
            }

            // Dream symbols
            if !dream.symbols.isEmpty {
                HStack(spacing: 6) {
                    ForEach(dream.symbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.12))
                            )
                    }
                }
            }
        }
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
        )
    }
}
