import SwiftUI

struct DivinationResultSheet: View {
    let divination: Divination
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1A1040"), Color(hex: "311B92")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: DreamSpacing.xl) {
                Spacer()

                // Title - 本卦
                VStack(spacing: DreamSpacing.sm) {
                    Text("【\(divination.hexagramName ?? "落叶")】卦")
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundStyle(.white)

                    if let meaning = divination.hexagramMeaning {
                        Text(meaning)
                            .font(.system(size: 15, weight: .light))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    // 如果有变卦
                    if let transformedName = divination.transformedHexagramName,
                       let transformedMeaning = divination.transformedHexagramMeaning {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.5))

                            Text("变为【\(transformedName)】卦")
                                .font(.system(size: 16, weight: .medium, design: .serif))
                                .foregroundStyle(Color.auroraLavender)
                        }
                        .padding(.top, 4)

                        Text(transformedMeaning)
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                // Hexagram or leaf display
                if divination.hexagramName != nil {
                    // 新版六爻卦象
                    HStack(spacing: 40) {
                        // 本卦
                        VStack(spacing: 4) {
                            Text("本卦")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.5))

                            VStack(spacing: 6) {
                                ForEach(divination.leaves.indices.reversed(), id: \.self) { index in
                                    if let yaoType = DivinationService.YaoType(rawValue: divination.leaves[index]) {
                                        HStack(spacing: 4) {
                                            Text(yaoType.symbol)
                                                .font(.system(size: 20, weight: .medium, design: .monospaced))
                                                .foregroundStyle(
                                                    yaoType.isMoving ?
                                                    Color.auroraLavender : .white.opacity(0.9)
                                                )

                                            if yaoType.isMoving {
                                                let yaoNames = ["初", "二", "三", "四", "五", "上"]
                                                Text("\(yaoNames[index])爻")
                                                    .font(.system(size: 10))
                                                    .foregroundStyle(Color.auroraLavender.opacity(0.7))
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 变卦（如果有）
                        if divination.transformedHexagramName != nil {
                            VStack(spacing: 4) {
                                Text("变卦")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.5))

                                VStack(spacing: 6) {
                                    ForEach(divination.leaves.indices.reversed(), id: \.self) { index in
                                        if let yaoType = DivinationService.YaoType(rawValue: divination.leaves[index]) {
                                            let transformed = yaoType.transformed
                                            Text(transformed.symbol.replacingOccurrences(of: " ○", with: "").replacingOccurrences(of: " ×", with: ""))
                                                .font(.system(size: 20, weight: .medium, design: .monospaced))
                                                .foregroundStyle(.white.opacity(0.7))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, DreamSpacing.md)
                } else {
                    // 旧版叶子占卜
                    HStack(spacing: DreamSpacing.lg) {
                        ForEach(divination.leaves.prefix(3), id: \.self) { leafName in
                            let leafType = DivinationService.leafTypes.first(where: { $0.name == leafName })
                            VStack(spacing: DreamSpacing.sm) {
                                Circle()
                                    .fill(Color(hex: leafType?.colorHex ?? "D1C4E9").opacity(0.6))
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Image(systemName: "leaf.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(.white.opacity(0.8))
                                    }

                                Text(leafName)
                                    .font(.system(size: 14, weight: .medium, design: .serif))
                                    .foregroundStyle(.white)

                                if let meaning = leafType?.meaning {
                                    Text(meaning)
                                        .font(.system(size: 11))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        }
                    }
                    .padding(.vertical, DreamSpacing.md)
                }

                // Interpretation
                ScrollView {
                    Text(divination.interpretation)
                        .font(.system(size: 15, weight: .light, design: .serif))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineSpacing(8)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, DreamSpacing.xl)
                }
                .frame(maxHeight: 250)

                Spacer()

                // Dismiss button
                Button {
                    onDismiss()
                } label: {
                    Text("了解")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, DreamSpacing.xxl)
                        .padding(.vertical, DreamSpacing.md)
                        .background(
                            Capsule()
                                .fill(Color.auroraLavender.opacity(0.4))
                        )
                }
                .padding(.bottom, DreamSpacing.xxl)
            }
        }
        .presentationDetents([.large])
    }
}
