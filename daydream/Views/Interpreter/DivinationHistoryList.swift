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
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        // 支持新版（卦象）和旧版（叶子）
                        if let hexagramName = divination.hexagramName {
                            Text("【\(hexagramName)】")
                                .font(.system(size: 13, weight: .medium, design: .serif))
                                .foregroundStyle(.white.opacity(0.9))

                            if let transformedName = divination.transformedHexagramName {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.white.opacity(0.4))

                                Text("【\(transformedName)】")
                                    .font(.system(size: 12, weight: .medium, design: .serif))
                                    .foregroundStyle(Color.auroraLavender.opacity(0.8))
                            }
                        } else {
                            // 旧版叶子占卜
                            Text("落叶问签")
                                .font(.system(size: 13, weight: .medium, design: .serif))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }

                    if let meaning = divination.hexagramMeaning {
                        Text(meaning)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                Spacer()

                Text(divination.date.formatted(.dateTime.month().day().hour().minute()))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            }

            // Hexagram or leaf display
            HStack(spacing: 12) {
                // 尝试显示六爻卦象
                if divination.hexagramName != nil {
                    VStack(spacing: 2) {
                        ForEach(divination.leaves.indices.reversed(), id: \.self) { index in
                            if let yaoType = DivinationService.YaoType(rawValue: divination.leaves[index]) {
                                Text(yaoType.symbol)
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundStyle(
                                        yaoType.isMoving ?
                                        Color.auroraLavender.opacity(0.8) : .white.opacity(0.6)
                                    )
                            }
                        }
                    }
                } else {
                    // 旧版叶子显示
                    HStack(spacing: 4) {
                        ForEach(divination.leaves.prefix(3), id: \.self) { leaf in
                            let leafType = DivinationService.leafTypes.first(where: { $0.name == leaf })
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: leafType?.colorHex ?? "D1C4E9").opacity(0.6))
                        }
                    }
                }

                Text(divination.interpretation)
                    .font(.system(size: 13, weight: .light, design: .serif))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
                    .lineSpacing(4)
            }
        }
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.06))
        )
    }
}
