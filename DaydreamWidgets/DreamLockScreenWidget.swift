import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Lock Screen Widget (Rectangular, Circular, Inline)

struct DreamLockScreenWidget: Widget {
    let kind: String = "DreamLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DreamProvider()) { entry in
            DreamLockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("浮光梦境")
        .description("在锁屏上显示最近的梦境")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
    }
}

struct DreamLockScreenWidgetView: View {
    let entry: DreamEntry

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            rectangularView
        case .accessoryCircular:
            circularView
        case .accessoryInline:
            inlineView
        default:
            EmptyView()
        }
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let dream = entry.latestDream {
                HStack(spacing: 4) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 10))
                    Text(dream.worldName ?? "梦境")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(.secondary)

                Text(dream.poemFirstLine)
                    .font(.system(size: 12, weight: .light, design: .serif))
                    .lineLimit(2)
                    .foregroundStyle(.primary)
            } else {
                Text("暂无梦境")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var circularView: some View {
        ZStack {
            if let dream = entry.latestDream {
                Circle()
                    .fill(dream.emotionGradient)

                Image(systemName: dream.emotionIcon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            } else {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 10))
            if let dream = entry.latestDream {
                Text(dream.worldName ?? "梦境")
                    .font(.system(size: 12))
            } else {
                Text("暂无梦境")
                    .font(.system(size: 12))
            }
        }
    }
}

// MARK: - Timeline Provider

struct DreamProvider: TimelineProvider {
    func placeholder(in context: Context) -> DreamEntry {
        DreamEntry(date: Date(), latestDream: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (DreamEntry) -> Void) {
        let entry = DreamEntry(date: Date(), latestDream: fetchLatestDream())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DreamEntry>) -> Void) {
        let currentDate = Date()
        let entry = DreamEntry(date: currentDate, latestDream: fetchLatestDream())

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func fetchLatestDream() -> LatestDreamData? {
        let modelContainer = try? ModelContainer(for: Dream.self)
        guard let context = modelContainer?.mainContext else { return nil }

        let descriptor = FetchDescriptor<Dream>(
            sortBy: [SortDescriptor(\Dream.createdAt, order: .reverse)]
        )

        guard let dreams = try? context.fetch(descriptor),
              let latestDream = dreams.first else {
            return nil
        }

        return LatestDreamData(
            poem: latestDream.poem,
            worldName: latestDream.worldName,
            emotionName: latestDream.emotion.rawValue,
            emotionColors: latestDream.emotion.gradient.map { $0.description }
        )
    }
}

// MARK: - Timeline Entry

struct DreamEntry: TimelineEntry {
    let date: Date
    let latestDream: LatestDreamData?
}

struct LatestDreamData {
    let poem: String
    let worldName: String?
    let emotionName: String
    let emotionColors: [String]

    var poemFirstLine: String {
        poem.components(separatedBy: "\n").first ?? poem
    }

    var emotionIcon: String {
        switch emotionName {
        case "serenity": return "moon.stars.fill"
        case "melancholy": return "cloud.rain.fill"
        case "anxiety": return "bolt.fill"
        case "hope": return "sun.max.fill"
        case "whimsy": return "sparkles"
        default: return "moon.stars.fill"
        }
    }

    var emotionGradient: LinearGradient {
        // Parse color strings back to Color
        let colors = emotionColors.compactMap { colorString -> Color? in
            // This is a simplified parser - you may need to adjust based on Color description format
            switch emotionName {
            case "serenity": return Color.moonlightBlue
            case "melancholy": return Color.mistGray
            case "anxiety": return Color.stormPurple
            case "hope": return Color.sunriseGold
            case "whimsy": return Color.dreamPink
            default: return Color.moonlightBlue
            }
        }

        return LinearGradient(
            colors: colors.isEmpty ? [Color.moonlightBlue] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
