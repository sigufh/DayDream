import SwiftUI
import SpriteKit

struct VoiceCaptureView: View {
    let namespace: Namespace.ID
    let isVisible: Bool
    let onComplete: () -> Void
    let onDismiss: () -> Void

    @Environment(AppRouter.self) private var router
    @State private var audioRecorder = AudioRecorder()
    @State private var transcriber = SpeechTranscriber()
    @State private var hasPermission = false
    @State private var showPermissionAlert = false
    @State private var isFinishing = false
    @State private var showUI = false

    var body: some View {
        ZStack {
            // 从 Orb 位置向外扩散的背景
            CaptureBackgroundView(isExpanded: isVisible)

            // 内容层
            GeometryReader { geo in
                let contentWidth = geo.size.width

                VStack(spacing: 0) {
                    // ── 顶部：关闭按钮 ──
                    HStack {
                        Button {
                            audioRecorder.stopRecording()
                            transcriber.stopTranscribing()
                            LiveActivityManager.shared.endRecordingActivity()
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, DreamSpacing.md)

                    Spacer()

                    // ── 中心：情绪星球 ──
                    EmotionPlanetView(isSpeaking: transcriber.isSpeaking) {
                        finishRecording()
                    }
                    .matchedGeometryEffect(
                        id: "recordingOrb",
                        in: namespace,
                        isSource: false
                    )
                    .frame(width: contentWidth, height: 300)
                    .clipped()

                    // ── 星球下方：转录文本 ──
                    if !transcriber.transcript.isEmpty {
                        Text(transcriber.transcript)
                            .font(.system(size: 15, weight: .light))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .lineLimit(5)
                            .frame(width: contentWidth - 80, alignment: .center)
                            .frame(maxHeight: 120, alignment: .top)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: transcriber.transcript)
                    }

                    Spacer()

                    // ── 底部：提示文字 ──
                    Group {
                        if audioRecorder.isRecording {
                            VStack(spacing: DreamSpacing.sm) {
                                Text("轻触星球完成录制")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundStyle(.white.opacity(0.6))

                                Text("AI 将自动识别情绪")
                                    .font(.system(size: 11, weight: .light))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                        } else {
                            Text("轻触屏幕，开始倾诉你的梦")
                                .font(.system(size: 13, weight: .light))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .padding(.bottom, DreamSpacing.xxl)
                }
            }
            .opacity(showUI ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.3), value: showUI)
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showUI = true
                }
            } else {
                showUI = false
            }
        }
        .onAppear {
            if isVisible {
                showUI = true
            }
        }
        .task {
            let audioGranted = await audioRecorder.requestPermission()
            let speechGranted = await transcriber.requestPermission()
            hasPermission = audioGranted && speechGranted

            if hasPermission {
                audioRecorder.startRecording()
                transcriber.startTranscribing()
                LiveActivityManager.shared.startRecordingActivity()
            } else {
                showPermissionAlert = true
            }
        }
        .onChange(of: transcriber.transcript) { _, newTranscript in
            LiveActivityManager.shared.updateTranscript(newTranscript)
        }
        .alert("需要权限", isPresented: $showPermissionAlert) {
            Button("确定") {
                onDismiss()
            }
        } message: {
            Text("请在设置中允许麦克风和语音识别权限")
        }
    }

    private func finishRecording() {
        guard !isFinishing else { return }
        isFinishing = true

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        let savedTranscript = transcriber.transcript

        audioRecorder.stopRecording()
        transcriber.stopTranscribing()
        LiveActivityManager.shared.endRecordingActivity()

        router.capturedTranscript = savedTranscript.isEmpty ? "梦的碎片…" : savedTranscript
        router.capturedEmotion = .serenity
        router.capturedAudioURL = audioRecorder.recordingURL

        onComplete()
    }
}
