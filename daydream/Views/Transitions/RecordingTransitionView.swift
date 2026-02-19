import SwiftUI

// MARK: - 录音完成过渡：中央圆球扩散全屏

struct CaptureToProcessingOverlay: View {
    let phase: TransitionManager.AnimPhase

    @State private var circleScale: CGFloat = 0.3
    @State private var overlayOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // 全屏渐变底色（phase == covering 时完全不透明）
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.22),
                    Color.twilightCyanBlue
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(overlayOpacity)
            .ignoresSafeArea()

            // 从中心扩散的圆球
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.auroraLavender.opacity(0.6),
                            Color.glacierBlue.opacity(0.4),
                            Color.twilightCyanBlue
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 500
                    )
                )
                .scaleEffect(circleScale)
                .opacity(overlayOpacity)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .allowsHitTesting(true)
        .onAppear {
            driveAnimation()
        }
        .onChange(of: phase) { _, _ in
            driveAnimation()
        }
    }

    private func driveAnimation() {
        switch phase {
        case .expanding:
            // 圆球从小到全屏
            withAnimation(.easeOut(duration: 0.35)) {
                circleScale = 3.0
                overlayOpacity = 1.0
            }

        case .covering:
            // 保持完全不透明
            circleScale = 3.0
            overlayOpacity = 1.0

        case .revealing:
            // 淡出揭开新页面
            withAnimation(.easeOut(duration: 0.6)) {
                overlayOpacity = 0.0
            }
        }
    }
}

// MARK: - 处理完成过渡：浮光拓印

struct ProcessingToCurationOverlay: View {
    let phase: TransitionManager.AnimPhase

    @State private var ringScale: CGFloat = 0.2
    @State private var rotation: Double = 0
    @State private var overlayOpacity: Double = 0.0
    @State private var brightness: Double = 0.0

    var body: some View {
        ZStack {
            // 底色
            Color.pearlWhite
                .opacity(brightness)
                .ignoresSafeArea()

            // 渐变遮罩
            LinearGradient(
                colors: [
                    Color.auroraLavender.opacity(0.4),
                    Color.glacierBlue.opacity(0.3),
                    Color.pearlWhite.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(overlayOpacity)
            .ignoresSafeArea()

            // 旋转光环
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color.auroraLavender,
                                Color.glacierBlue,
                                Color.auroraLavender
                            ],
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(ringScale + CGFloat(index) * 0.3)
                    .rotationEffect(.degrees(rotation + Double(index) * 120))
                    .opacity(overlayOpacity * 0.6)
            }

            // 中心光点
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            Color.auroraLavender.opacity(0.5),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .blur(radius: 15)
                .scaleEffect(ringScale)
                .opacity(overlayOpacity)
        }
        .ignoresSafeArea()
        .allowsHitTesting(true)
        .onAppear {
            driveAnimation()
        }
        .onChange(of: phase) { _, _ in
            driveAnimation()
        }
    }

    private func driveAnimation() {
        switch phase {
        case .expanding:
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                ringScale = 5.0
                overlayOpacity = 1.0
                brightness = 0.8
            }
            withAnimation(.linear(duration: 0.8)) {
                rotation = 360
            }

        case .covering:
            overlayOpacity = 1.0
            brightness = 1.0

        case .revealing:
            withAnimation(.easeOut(duration: 0.6)) {
                overlayOpacity = 0.0
                brightness = 0.0
            }
        }
    }
}
