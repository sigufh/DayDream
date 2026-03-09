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
    @State private var inputMode: InputMode = .voice  // 输入模式
    @State private var textInput: String = ""  // 文本输入内容
    @FocusState private var isTextFieldFocused: Bool

    enum InputMode {
        case voice
        case text
    }

    // 统一的文本内容（语音转录或文本输入）
    var currentTranscript: String {
        inputMode == .voice ? transcriber.transcript : textInput
    }

    var body: some View {
        ZStack {
            // 从 Orb 位置向外扩散的背景
            CaptureBackgroundView(isExpanded: isVisible)

            // 内容层
            GeometryReader { geo in
                let contentWidth = geo.size.width

                VStack(spacing: 0) {
                    // ── 顶部：关闭按钮和模式切换 ──
                    HStack {
                        Button {
                            cleanup()
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }

                        Spacer()

                        // 模式切换按钮
                        Button {
                            switchInputMode()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: inputMode == .voice ? "keyboard" : "mic.fill")
                                    .font(.system(size: 14))
                                Text(inputMode == .voice ? "文字" : "语音")
                                    .font(.system(size: 13))
                            }
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.15))
                            )
                        }
                    }
                    .padding(.horizontal, DreamSpacing.md)

                    Spacer()

                    if inputMode == .voice {
                        // ── 语音模式：情绪星球 ──
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
                        }
                    } else {
                        // ── 文本模式：输入框 ──
                        VStack(spacing: DreamSpacing.lg) {
                            // 文本编辑器
                            TextEditor(text: $textInput)
                                .font(.system(size: 16, weight: .light))
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .scrollDismissesKeyboard(.interactively)
                                .frame(height: 200)
                                .padding(DreamSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .focused($isTextFieldFocused)

                            if textInput.isEmpty {
                                Text("在这里输入你的梦境...")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .padding(.top, -220)
                                    .allowsHitTesting(false)
                            }

                            // 完成按钮
                            Button {
                                finishRecording()
                            } label: {
                                HStack(spacing: 8) {
                                    Text("完成")
                                        .font(.system(size: 16, weight: .medium))
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DreamSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.auroraLavender.opacity(textInput.isEmpty ? 0.3 : 0.8))
                                )
                            }
                            .disabled(textInput.isEmpty)
                        }
                        .padding(.horizontal, DreamSpacing.xl)
                        .frame(height: 300)
                    }

                    Spacer()

                    // ── 底部：提示文字 ──
                    Group {
                        if inputMode == .voice {
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
                        } else {
                            Text("记录完成后点击完成按钮")
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
            if inputMode == .voice {
                LiveActivityManager.shared.updateTranscript(newTranscript)
            }
        }
        .onChange(of: textInput) { _, newText in
            if inputMode == .text {
                LiveActivityManager.shared.updateTranscript(newText)
            }
        }
        .alert("需要权限", isPresented: $showPermissionAlert) {
            Button("确定") {
                onDismiss()
            }
        } message: {
            Text("请在设置中允许麦克风和语音识别权限")
        }
    }

    private func switchInputMode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if inputMode == .voice {
            // 切换到文本模式
            audioRecorder.stopRecording()
            transcriber.stopTranscribing()
            LiveActivityManager.shared.endRecordingActivity()

            // 保留已转录的文本
            textInput = transcriber.transcript
            inputMode = .text

            // 自动聚焦到文本框
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        } else {
            // 切换到语音模式
            inputMode = .voice
            isTextFieldFocused = false

            // 如果有权限，开始录音
            if hasPermission {
                audioRecorder.startRecording()
                transcriber.startTranscribing()
                LiveActivityManager.shared.startRecordingActivity()
            }
        }
    }

    private func cleanup() {
        audioRecorder.stopRecording()
        transcriber.stopTranscribing()
        LiveActivityManager.shared.endRecordingActivity()
    }

    private func finishRecording() {
        guard !isFinishing else { return }
        isFinishing = true

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // 使用统一的文本内容
        let savedTranscript = currentTranscript

        cleanup()

        router.capturedTranscript = savedTranscript.isEmpty ? "梦的碎片…" : savedTranscript
        router.capturedEmotion = .serenity
        router.capturedAudioURL = inputMode == .voice ? audioRecorder.recordingURL : nil

        onComplete()
    }
}
