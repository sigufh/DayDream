import SwiftUI

/// Siri风格的炫彩光球录音按钮
struct SiriLikeOrbView: View {
    let onTap: () -> Void

    @State private var isAnimating = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onTap()
        }) {
            ZStack {
                // 背景光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 32
                        )
                    )
                    .frame(width: 64, height: 64)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0.6 : 0.3)

                // 外层光环
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(red: 0.4, green: 0.8, blue: 1.0),
                                Color(red: 0.8, green: 0.4, blue: 1.0),
                                Color(red: 1.0, green: 0.6, blue: 0.8),
                                Color(red: 1.0, green: 0.8, blue: 0.4),
                                Color(red: 0.4, green: 1.0, blue: 0.8),
                                Color(red: 0.4, green: 0.8, blue: 1.0)
                            ],
                            center: .center,
                            angle: .degrees(rotation)
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 52, height: 52)
                    .blur(radius: 1.5)

                // 中间炫彩球体
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.8, blue: 1.0),
                                Color(red: 0.8, green: 0.5, blue: 1.0),
                                Color(red: 1.0, green: 0.7, blue: 0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay {
                        // 高光效果
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.8),
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    center: UnitPoint(x: 0.3, y: 0.3),
                                    startRadius: 0,
                                    endRadius: 22
                                )
                            )
                    }
                    .scaleEffect(scale)

                // 内层脉动光点
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 16, height: 16)
                    .blur(radius: 2.5)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0 : 0.8)

                // 波纹效果
                ForEach(0..<2, id: \.self) { index in
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 44, height: 44)
                        .scaleEffect(isAnimating ? 1.6 : 1.0)
                        .opacity(isAnimating ? 0 : 0.5)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4),
                            value: isAnimating
                        )
                }
            }
            .frame(width: 64, height: 64)
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            // 持续旋转动画
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            // 脉动动画
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }

            // 缩放动画
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.08
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
