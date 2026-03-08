import SwiftUI

struct FallingLeavesOverlay: View {
    let onComplete: ([DivinationService.YaoType]) -> Void

    @State private var currentThrow = 0
    @State private var yaos: [DivinationService.YaoType] = []
    @State private var isFlipping = false
    @State private var showResult = false

    var body: some View {
        ZStack {
            // 半透明黑色背景
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // 显示当前第几爻
                if currentThrow < 6 {
                    Text("第\(["一", "二", "三", "四", "五", "六"][currentThrow])爻")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundStyle(.white)
                } else {
                    Text("卦象已成")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundStyle(.white)
                }

                // 抛掷的叶子动画
                if isFlipping {
                    FlippingLeaf()
                        .frame(width: 80, height: 80)
                }

                // 已形成的爻（从下往上显示）
                VStack(spacing: 8) {
                    ForEach(yaos.indices.reversed(), id: \.self) { index in
                        Text(yaos[index].symbol)
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(minHeight: 200)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            performThrows()
        }
    }

    private func performThrows() {
        guard currentThrow < 6 else {
            // 六爻完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onComplete(yaos)
            }
            return
        }

        // 开始翻转动画
        isFlipping = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // 0.8秒后显示结果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let yao = DivinationService.YaoType.throwCoins()
            withAnimation {
                yaos.append(yao)
                isFlipping = false
                currentThrow += 1
            }

            // 显示动爻的额外反馈
            if yao.isMoving {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }

            // 继续下一次抛掷
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                performThrows()
            }
        }
    }
}

// 翻转的叶子动画
private struct FlippingLeaf: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: 60))
            .foregroundStyle(Color.auroraLavender)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 1, y: 1, z: 0)
            )
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    scale = 1.2
                }
            }
    }
}
