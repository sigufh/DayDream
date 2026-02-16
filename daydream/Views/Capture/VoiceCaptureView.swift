import SwiftUI
import SpriteKit

struct VoiceCaptureView: View {
    @Environment(AppRouter.self) private var router
    @State private var audioRecorder = AudioRecorder()
    @State private var transcriber = SpeechTranscriber()
    @State private var selectedEmotion: DreamEmotion = .serenity
    @State private var hasPermission = false
    @State private var showPermissionAlert = false
    @State private var isFinishing = false
    @State private var scene = CaptureParticleScene()

    var body: some View {
        ZStack {
            Color.twilightCyanBlue.ignoresSafeArea()

            // SpriteKit particle overlay
            StarSphereView(scene: scene) {
                finishRecording()
            }

            // UI overlay
            VStack {
                // Close button
                HStack {
                    Button {
                        audioRecorder.stopRecording()
                        transcriber.stopTranscribing()
                        router.dismissToGallery()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .light))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, DreamSpacing.md)

                Spacer()

                // Transcript display
                if !transcriber.transcript.isEmpty {
                    Text(transcriber.transcript)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DreamSpacing.xl)
                        .padding(.bottom, DreamSpacing.xxl)
                        .transition(.opacity)
                }

                // Hint
                if !audioRecorder.isRecording {
                    Text("轻触星辰，开始倾诉你的梦")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, DreamSpacing.xl)
                } else {
                    Text("轻触中央星球完成录制")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, DreamSpacing.xl)
                }

                // Emotion selector
                HStack(spacing: DreamSpacing.md) {
                    ForEach(DreamEmotion.allCases) { emotion in
                        Button {
                            selectedEmotion = emotion
                        } label: {
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(emotion.primaryColor)
                                    .frame(width: selectedEmotion == emotion ? 28 : 20,
                                           height: selectedEmotion == emotion ? 28 : 20)
                                    .overlay {
                                        if selectedEmotion == emotion {
                                            Circle()
                                                .stroke(.white, lineWidth: 1.5)
                                        }
                                    }

                                Text(emotion.displayName)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
                }
                .padding(.bottom, DreamSpacing.lg)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: transcriber.transcript)
        .task {
            let audioGranted = await audioRecorder.requestPermission()
            let speechGranted = await transcriber.requestPermission()
            hasPermission = audioGranted && speechGranted

            if hasPermission {
                audioRecorder.startRecording()
                transcriber.startTranscribing()
            } else {
                showPermissionAlert = true
            }
        }
        .onChange(of: transcriber.isSpeaking) { _, speaking in
            scene.updateSpeaking(speaking)
        }
        .alert("需要权限", isPresented: $showPermissionAlert) {
            Button("确定") {
                router.dismissToGallery()
            }
        } message: {
            Text("请在设置中允许麦克风和语音识别权限")
        }
    }

    private func finishRecording() {
        guard !isFinishing else { return }
        isFinishing = true

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        scene.lockColor(emotion: selectedEmotion)
        audioRecorder.stopRecording()
        transcriber.stopTranscribing()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            router.finishCapture(
                transcript: transcriber.transcript.isEmpty ? "梦的碎片…" : transcriber.transcript,
                emotion: selectedEmotion,
                audioURL: audioRecorder.recordingURL
            )
        }
    }
}
