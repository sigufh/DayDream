import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Divination.date, order: .reverse) private var divinations: [Divination]
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]

    var body: some View {
        ScrollView {
            VStack(spacing: DreamSpacing.xl) {
                Spacer()
                    .frame(height: DreamSpacing.md)

                // 问签记录
                if !divinations.isEmpty {
                    VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                        Text("问签记录")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, DreamSpacing.md)

                        DivinationHistoryList(divinations: divinations)
                            .padding(.horizontal, DreamSpacing.md)
                    }
                }

                // 梦境记录
                if !dreams.isEmpty {
                    VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                        Text("梦境记录")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, DreamSpacing.md)

                        LazyVStack(spacing: DreamSpacing.sm) {
                            ForEach(dreams.prefix(10)) { dream in
                                DreamHistoryRow(dream: dream)
                            }
                        }
                        .padding(.horizontal, DreamSpacing.md)
                    }
                }

                if divinations.isEmpty && dreams.isEmpty {
                    emptyState
                }

                Spacer()
                    .frame(height: 120)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DreamSpacing.lg) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(Color.auroraLavender.opacity(0.5))

            VStack(spacing: DreamSpacing.sm) {
                Text("暂无记录")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundStyle(.white)

                Text("记录你的梦境和占卜，开始探索内在世界")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, DreamSpacing.xl)
        .padding(.top, 100)
    }
}

private struct DreamHistoryRow: View {
    let dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
            HStack {
                Text(dream.createdAt.formatted(.dateTime.month().day().hour().minute()))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))

                Spacer()

                Text(dream.emotion.displayName)
                    .font(.system(size: 11))
                    .foregroundStyle(dream.emotion.primaryColor)
            }

            Text(dream.transcript)
                .font(.system(size: 13, weight: .light, design: .serif))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(2)
                .lineSpacing(4)

            if !dream.symbols.isEmpty {
                HStack(spacing: 6) {
                    ForEach(dream.symbols.prefix(5), id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.06))
        )
    }
}
