import SwiftUI

struct DivinationHistoryList: View {
    let divinations: [Divination]

    var body: some View {
        LazyVStack(spacing: DreamSpacing.sm) {
            ForEach(divinations) { divination in
                DivinationHistoryRow(divination: divination)
            }
        }
    }
}

private struct DivinationHistoryRow: View {
    let divination: Divination

    var body: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
            HStack {
                Text(divination.date.formatted(.dateTime.month().day().hour().minute()))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))

                Spacer()
            }

            // Leaf tags
            HStack(spacing: 6) {
                ForEach(divination.leaves, id: \.self) { leaf in
                    let leafType = DivinationService.leafTypes.first(where: { $0.name == leaf })
                    Text(leaf)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(hex: leafType?.colorHex ?? "D1C4E9").opacity(0.3))
                        )
                }
            }

            Text(divination.interpretation)
                .font(.system(size: 13, weight: .light, design: .serif))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(3)
                .lineSpacing(4)
        }
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.06))
        )
    }
}
