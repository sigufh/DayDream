import SwiftUI

/// 录音页面背景 - 从 Orb 位置向外扩散的圆形遮罩
struct CaptureBackgroundView: View {
    let isExpanded: Bool

    @State private var maskScale: CGFloat = 0.01
    @State private var backgroundOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // 深色背景
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(backgroundOpacity)

            // 扩散的光晕效果
            RadialGradient(
                colors: [
                    Color(red: 0.5, green: 0.8, blue: 1.0).opacity(0.2),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            .scaleEffect(maskScale)
            .opacity(backgroundOpacity * 0.5)
        }
        .onChange(of: isExpanded) { _, expanded in
            if expanded {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    maskScale = 8.0
                }
                withAnimation(.easeOut(duration: 0.4)) {
                    backgroundOpacity = 1.0
                }
            } else {
                maskScale = 0.01
                backgroundOpacity = 0.0
            }
        }
        .onAppear {
            if isExpanded {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    maskScale = 8.0
                }
                withAnimation(.easeOut(duration: 0.4)) {
                    backgroundOpacity = 1.0
                }
            }
        }
    }
}
