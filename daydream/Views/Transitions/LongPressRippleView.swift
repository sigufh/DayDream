import SwiftUI

/// 长按时的即时涟漪反馈
struct LongPressRippleView: View {
    let position: CGPoint
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        if position.x.isFinite && position.y.isFinite && position.x >= 0 && position.y >= 0 {
            ZStack {
                // 外圈涟漪
                Circle()
                    .stroke(Color.auroraLavender.opacity(0.6), lineWidth: 2)
                    .frame(width: 60, height: 60)
                    .scaleEffect(scale)
                    .opacity(opacity)

                // 中圈涟漪
                Circle()
                    .stroke(Color.auroraLavender.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 40, height: 40)
                    .scaleEffect(scale * 0.8)
                    .opacity(opacity)

                // 内圈光点
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white,
                                Color.auroraLavender.opacity(0.8),
                                Color.auroraLavender.opacity(0.3)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 30, height: 30)
                    .scaleEffect(scale * 0.6)
            }
            .position(position)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    scale = 2.5
                    opacity = 0
                }
            }
        }
    }
}
