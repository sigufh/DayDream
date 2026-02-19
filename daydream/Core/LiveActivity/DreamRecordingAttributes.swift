import ActivityKit
import Foundation

// MARK: - Live Activity Attributes (Shared between app and widget)

struct DreamRecordingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var duration: TimeInterval
        var transcriptPreview: String
    }

    var startTime: Date
}
