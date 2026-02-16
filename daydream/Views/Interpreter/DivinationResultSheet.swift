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

                // Title
                Text("叶落有声")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundStyle(.white)
                    .tracking(4)

                // Leaf display
                HStack(spacing: DreamSpacing.lg) {
                    ForEach(divination.leaves, id: \.self) { leafName in
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

                            Text(leafType?.meaning ?? "")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }

                // Interpretation
                Text(divination.interpretation)
                    .font(.system(size: 15, weight: .light, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DreamSpacing.xl)

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
