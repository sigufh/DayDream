import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget
// Note: DreamRecordingAttributes is defined in the shared file:
// daydream/Core/LiveActivity/DreamRecordingAttributes.swift

struct DreamLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DreamRecordingAttributes.self) { context in
            // Lock screen / banner UI
            DreamLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded region
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.auroraLavender)
                            .symbolEffect(.variableColor.iterative)

                        Text("记录中")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatDuration(context.state.duration))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        if !context.state.transcriptPreview.isEmpty {
                            Text(context.state.transcriptPreview)
                                .font(.system(size: 11, design: .serif))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("正在聆听...")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.auroraLavender)

                        Text("长按说出梦境")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } compactLeading: {
                // Compact leading (Dynamic Island minimal state)
                Image(systemName: "waveform")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.auroraLavender)
                    .symbolEffect(.variableColor.iterative)
            } compactTrailing: {
                // Compact trailing (Dynamic Island minimal state)
                Text(formatDuration(context.state.duration))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            } minimal: {
                // Minimal state (when multiple Live Activities are active)
                Image(systemName: "waveform")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.auroraLavender)
            }
            .keylineTint(Color.auroraLavender)
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Lock Screen / Banner View

struct DreamLiveActivityView: View {
    let context: ActivityViewContext<DreamRecordingAttributes>

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.auroraLavender.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: "waveform")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.auroraLavender)
                    .symbolEffect(.variableColor.iterative)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("记录梦境")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(formatDuration(context.state.duration))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                if !context.state.transcriptPreview.isEmpty {
                    Text(context.state.transcriptPreview)
                        .font(.system(size: 11, design: .serif))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                } else {
                    Text("正在聆听...")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(12)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview("Dynamic Island", as: .dynamicIsland) {
    DreamLiveActivity()
} attributes: {
    DreamRecordingAttributes(startTime: Date())
} contentState: {
    DreamRecordingAttributes.ContentState(
        duration: 23,
        transcriptPreview: "我梦见了一只白色的猫..."
    )
}
