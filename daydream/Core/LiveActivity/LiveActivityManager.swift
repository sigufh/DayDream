import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private var currentActivity: Activity<DreamRecordingAttributes>?
    private var updateTimer: Timer?

    private init() {}

    func startRecordingActivity() {
        // End any existing activity
        endRecordingActivity()

        let attributes = DreamRecordingAttributes(startTime: Date())
        let initialState = DreamRecordingAttributes.ContentState(
            duration: 0,
            transcriptPreview: ""
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil)
            )
            currentActivity = activity

            // Start timer to update duration
            startUpdateTimer(startTime: attributes.startTime)

            print("Live Activity started: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updateTranscript(_ transcript: String) {
        guard let activity = currentActivity else { return }

        Task {
            let duration = Date().timeIntervalSince(activity.attributes.startTime)
            let preview = String(transcript.prefix(50))

            let updatedState = DreamRecordingAttributes.ContentState(
                duration: duration,
                transcriptPreview: preview
            )

            await activity.update(
                .init(state: updatedState, staleDate: nil)
            )
        }
    }

    func endRecordingActivity() {
        updateTimer?.invalidate()
        updateTimer = nil

        guard let activity = currentActivity else { return }

        Task {
            await activity.end(
                .init(
                    state: activity.content.state,
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )
            currentActivity = nil
            print("Live Activity ended")
        }
    }

    private func startUpdateTimer(startTime: Date) {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let activity = self.currentActivity else { return }

            Task { @MainActor in
                let duration = Date().timeIntervalSince(startTime)
                let currentState = activity.content.state

                let updatedState = DreamRecordingAttributes.ContentState(
                    duration: duration,
                    transcriptPreview: currentState.transcriptPreview
                )

                await activity.update(
                    .init(state: updatedState, staleDate: nil)
                )
            }
        }
    }
}
