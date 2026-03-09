import SwiftUI

struct PolaroidDreamCardBack: View {
    @Bindable var dream: Dream
    @FocusState private var isDiaryFocused: Bool
    @FocusState private var isPoemFocused: Bool

    private let cardWidth: CGFloat = 340

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DreamSpacing.md) {
                Text("梦境日记")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundStyle(Color.deepBlueGray)
                    .tracking(2)
                    .padding(.top, DreamSpacing.lg)

                TextEditor(text: Binding(
                    get: { dream.diary ?? "" },
                    set: { dream.diary = $0.isEmpty ? nil : $0 }
                ))
                .font(.system(size: 13, weight: .light, design: .serif))
                .foregroundStyle(Color.deepBlueGray)
                .lineSpacing(4)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(DreamSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.3))
                )
                .focused($isDiaryFocused)
                .overlay(alignment: .topLeading) {
                    if dream.diary == nil || dream.diary?.isEmpty == true {
                        Text("轻触编辑你的梦境日记...")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.mistyBlue)
                            .padding(.top, DreamSpacing.sm + 4)
                            .padding(.leading, DreamSpacing.sm + 4)
                            .allowsHitTesting(false)
                    }
                }

                Rectangle()
                    .fill(Color.linen)
                    .frame(height: 1)
                    .padding(.vertical, DreamSpacing.sm)

                Text("梦境归纳")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.mistyBlue)

                Text(dream.transcript)
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(Color.deepBlueGray)
                    .lineSpacing(4)

                HStack(spacing: DreamSpacing.md) {
                    HStack(spacing: 4) {
                        Text("情绪")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.mistyBlue)
                        Text(dream.emotion.displayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(dream.emotion.primaryColor)
                    }

                    if !dream.symbols.isEmpty {
                        ForEach(dream.symbols.prefix(3), id: \.self) { symbol in
                            Text(symbol)
                                .font(.system(size: 10))
                                .foregroundStyle(Color.deepBlueGray)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.linen.opacity(0.8))
                                )
                        }
                    }
                }
                .padding(.top, DreamSpacing.sm)

                Rectangle()
                    .fill(Color.linen)
                    .frame(height: 1)
                    .padding(.vertical, DreamSpacing.sm)

                Text("梦境诗句")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.mistyBlue)

                TextEditor(text: $dream.poem)
                    .font(.system(size: 13, weight: .light, design: .serif))
                    .foregroundStyle(Color.deepBlueGray)
                    .lineSpacing(4)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
                    .padding(DreamSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.3))
                    )
                    .focused($isPoemFocused)

                Spacer(minLength: DreamSpacing.lg)
            }
            .padding(.horizontal, DreamSpacing.lg)
            .padding(.bottom, DreamSpacing.lg)
        }
        .frame(width: cardWidth)
        .background(Color.pearlWhite)
        .clipShape(RoundedRectangle(cornerRadius: DreamSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        .scrollDismissesKeyboard(.interactively)
    }
}
