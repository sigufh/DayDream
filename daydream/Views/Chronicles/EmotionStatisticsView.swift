import SwiftUI

struct EmotionStatisticsView: View {
    let dreams: [Dream]

    private var dominantEmotion: DreamEmotion {
        var counts: [DreamEmotion: Int] = [:]
        for dream in dreams {
            counts[dream.emotion, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? .serenity
    }

    private var poeticSummary: String {
        switch dominantEmotion {
        case .serenity:
            return "近来的梦境如湖面般宁静，内心正在柔软地安放自己。"
        case .melancholy:
            return "淡淡的忧愁在梦中流淌，或许是心底的思念正在浮现。"
        case .anxiety:
            return "梦境中弥漫着不安的气息，给自己多一些温柔的喘息吧。"
        case .hope:
            return "星光在梦里闪烁，你的内心正在积蓄前行的力量。"
        case .whimsy:
            return "奇幻的梦境接踵而来，你的想象力正在编织一个瑰丽世界。"
        }
    }

    var body: some View {
        if dreams.isEmpty {
            ChroniclesEmptyStateView(
                icon: "paintpalette",
                title: "情绪光谱尚未显现",
                subtitle: "记录第一个梦境，让色彩开始流淌"
            )
        } else {
            ScrollView {
                VStack(spacing: DreamSpacing.xl) {
                    Spacer()
                        .frame(height: DreamSpacing.md)

                    EmotionSphereCanvas(dreams: dreams)

                    Text(poeticSummary)
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundStyle(Color.deepBlueGray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, DreamSpacing.xl)

                    SolarTermBarView()

                    Spacer()
                        .frame(height: DreamSpacing.lg)
                }
            }
        }
    }
}

struct ChroniclesEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: DreamSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.auroraLavender.opacity(0.5))

            VStack(spacing: DreamSpacing.sm) {
                Text(title)
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundStyle(Color.deepBlueGray)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.mistyBlue)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, DreamSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
