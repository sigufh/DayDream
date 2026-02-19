import SwiftUI

/// 织梦网过渡动画 - 从触摸点开始涟漪扩散形成网状结构
struct DreamWebTransitionView: View {
    let touchPoint: CGPoint
    let onComplete: () -> Void

    @State private var rippleProgress: CGFloat = 0
    @State private var webOpacity: Double = 0
    @State private var nodes: [WebNode] = []

    var body: some View {
        ZStack {
            // 背景渐变 - 逐渐变为录音界面的颜色
            Color.pearlWhite
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.twilightCyanBlue.opacity(rippleProgress * 0.3),
                            Color.twilightCyanBlue.opacity(rippleProgress * 0.6),
                            Color.twilightCyanBlue.opacity(rippleProgress)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()

            // 织梦网
            Canvas { context, size in
                // 绘制多层涟漪圆圈
                let maxRadius = sqrt(pow(size.width, 2) + pow(size.height, 2))
                let rippleCount = 12

                for i in 0..<rippleCount {
                    let delay = CGFloat(i) * 0.08
                    let progress = max(0, rippleProgress - delay)
                    guard progress > 0 else { continue }

                    let radius = maxRadius * progress
                    let opacity = max(0, 1 - progress) * (0.4 - CGFloat(i) * 0.02)
                    let lineWidth: CGFloat = i % 2 == 0 ? 2 : 1

                    let circlePath = Circle()
                        .path(in: CGRect(
                            x: touchPoint.x - radius,
                            y: touchPoint.y - radius,
                            width: radius * 2,
                            height: radius * 2
                        ))

                    context.stroke(
                        circlePath,
                        with: .color(Color.auroraLavender.opacity(opacity)),
                        lineWidth: lineWidth
                    )
                }

                // 绘制网格节点和连线
                if rippleProgress > 0.25 {
                    drawWebNodes(context: context, size: size)
                }
            }

            // 中心光点 - 扩散效果
            ZStack {
                // 外层光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.auroraLavender.opacity(0.3),
                                Color.auroraLavender.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(rippleProgress * 3)
                    .opacity(1 - rippleProgress)

                // 中心亮点
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white,
                                Color.auroraLavender,
                                Color.auroraLavender.opacity(0.5)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)
                    .scaleEffect(1.0 + rippleProgress * 0.5)
                    .opacity(Double(max(0, 1.0 - rippleProgress * 1.5)))
            }
            .position(touchPoint)

            // 粒子效果
            if rippleProgress > 0.2 && touchPoint.x.isFinite && touchPoint.y.isFinite {
                ForEach(0..<20, id: \.self) { index in
                    let angle = CGFloat(index) * .pi / 10
                    let distance = 100 * rippleProgress
                    let x = touchPoint.x + cos(angle) * distance
                    let y = touchPoint.y + sin(angle) * distance

                    if x.isFinite && y.isFinite && x >= 0 && y >= 0 {
                        Circle()
                            .fill(Color.auroraLavender)
                            .frame(width: 3, height: 3)
                            .position(x: x, y: y)
                            .opacity(Double(max(0, 1.0 - rippleProgress)))
                    }
                }
            }
        }
        .onAppear {
            generateWebNodes()
            animateRipple()
        }
    }

    private func generateWebNodes() {
        // 生成网格节点
        let rows = 8
        let cols = 6

        var generatedNodes: [WebNode] = []

        for row in 0..<rows {
            for col in 0..<cols {
                let x = CGFloat(col) * (UIScreen.main.bounds.width / CGFloat(cols - 1))
                let y = CGFloat(row) * (UIScreen.main.bounds.height / CGFloat(rows - 1))

                // 添加随机偏移，让网格更有机
                let offsetX = CGFloat.random(in: -20...20)
                let offsetY = CGFloat.random(in: -20...20)

                generatedNodes.append(WebNode(
                    position: CGPoint(x: x + offsetX, y: y + offsetY),
                    index: row * cols + col
                ))
            }
        }

        nodes = generatedNodes
    }

    private func drawWebNodes(context: GraphicsContext, size: CGSize) {
        let webProgress = min(1, (rippleProgress - 0.25) / 0.75)

        // 绘制连线 - 从触摸点向外扩散
        for (index, node) in nodes.enumerated() {
            let distanceFromTouch = sqrt(
                pow(node.position.x - touchPoint.x, 2) +
                pow(node.position.y - touchPoint.y, 2)
            )
            let maxDistance = sqrt(pow(size.width, 2) + pow(size.height, 2))
            let normalizedDistance = distanceFromTouch / maxDistance

            let cols = 6
            let row = index / cols
            let col = index % cols

            // 连接右侧节点
            if col < cols - 1 {
                let rightNode = nodes[index + 1]
                drawConnection(
                    context: context,
                    from: node.position,
                    to: rightNode.position,
                    progress: webProgress,
                    delay: normalizedDistance * 0.5
                )
            }

            // 连接下方节点
            if row < 7 {
                let bottomNode = nodes[index + cols]
                drawConnection(
                    context: context,
                    from: node.position,
                    to: bottomNode.position,
                    progress: webProgress,
                    delay: normalizedDistance * 0.5
                )
            }

            // 连接对角线节点（增加网状感）
            if col < cols - 1 && row < 7 {
                let diagonalNode = nodes[index + cols + 1]
                drawConnection(
                    context: context,
                    from: node.position,
                    to: diagonalNode.position,
                    progress: webProgress,
                    delay: normalizedDistance * 0.5,
                    opacity: 0.2
                )
            }
        }

        // 绘制节点 - 带脉动效果
        for (index, node) in nodes.enumerated() {
            let distanceFromTouch = sqrt(
                pow(node.position.x - touchPoint.x, 2) +
                pow(node.position.y - touchPoint.y, 2)
            )
            let maxDistance = sqrt(pow(size.width, 2) + pow(size.height, 2))
            let normalizedDistance = distanceFromTouch / maxDistance

            let delay = normalizedDistance * 0.5
            let nodeProgress = max(0, min(1, webProgress - delay))

            if nodeProgress > 0 {
                // 节点大小根据距离和进度变化
                let baseSize: CGFloat = 3
                let pulse = sin(rippleProgress * .pi * 4 - normalizedDistance * 10) * 0.5 + 0.5
                let nodeSize = baseSize + pulse * 2

                let nodeRect = CGRect(
                    x: node.position.x - nodeSize / 2,
                    y: node.position.y - nodeSize / 2,
                    width: nodeSize,
                    height: nodeSize
                )

                // 外层光晕
                let glowRect = CGRect(
                    x: node.position.x - nodeSize,
                    y: node.position.y - nodeSize,
                    width: nodeSize * 2,
                    height: nodeSize * 2
                )
                context.fill(
                    Circle().path(in: glowRect),
                    with: .color(Color.auroraLavender.opacity(nodeProgress * 0.2))
                )

                // 节点本体
                context.fill(
                    Circle().path(in: nodeRect),
                    with: .color(Color.auroraLavender.opacity(nodeProgress * 0.9))
                )
            }
        }
    }

    private func drawConnection(
        context: GraphicsContext,
        from: CGPoint,
        to: CGPoint,
        progress: CGFloat,
        delay: CGFloat,
        opacity: Double = 0.4
    ) {
        let lineProgress = max(0, min(1, progress - delay))

        if lineProgress > 0 {
            let currentTo = CGPoint(
                x: from.x + (to.x - from.x) * lineProgress,
                y: from.y + (to.y - from.y) * lineProgress
            )

            var path = Path()
            path.move(to: from)
            path.addLine(to: currentTo)

            // 使用渐变让连线更有层次
            let gradient = Gradient(colors: [
                Color.auroraLavender.opacity(lineProgress * opacity * 0.3),
                Color.auroraLavender.opacity(lineProgress * opacity)
            ])

            context.stroke(
                path,
                with: .linearGradient(
                    gradient,
                    startPoint: from,
                    endPoint: currentTo
                ),
                lineWidth: 1
            )
        }
    }

    private func animateRipple() {
        // 涟漪扩散动画
        withAnimation(.easeOut(duration: 1.5)) {
            rippleProgress = 1.2
        }

        // 网格淡入
        withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
            webOpacity = 1
        }

        // 完成后触发回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onComplete()
        }
    }
}

struct WebNode {
    let position: CGPoint
    let index: Int
}
