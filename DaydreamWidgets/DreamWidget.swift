import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Home Screen Widget (Small, Medium)

struct DreamWidget: Widget {
    let kind: String = "DreamWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DreamProvider()) { entry in
            DreamWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("浮光梦境")
        .description("显示最近的梦境诗句")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DreamWidgetView: View {
    let entry: DreamEntry

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        default:
            EmptyView()
        }
    }

    private var smallWidgetView: some View {
        ZStack {
            if let dream = entry.latestDream {
                // Background gradient
                dream.emotionGradient

                VStack(spacing: 8) {
                    Image(systemName: dream.emotionIcon)
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.9))

                    Text(dream.worldName ?? "梦境")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(dream.poemFirstLine)
                        .font(.system(size: 10, weight: .light, design: .serif))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                }
                .padding(12)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)

                    Text("暂无梦境")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var mediumWidgetView: some View {
        HStack(spacing: 12) {
            if let dream = entry.latestDream {
                // Left: Icon
                ZStack {
                    dream.emotionGradient
                    Image(systemName: dream.emotionIcon)
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Right: Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(dream.worldName ?? "梦境")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundStyle(.primary)

                    Text(dream.poem)
                        .font(.system(size: 11, weight: .light, design: .serif))
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.secondary)

                    Text("暂无梦境")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(16)
    }
}
