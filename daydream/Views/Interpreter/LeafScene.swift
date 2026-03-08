import SpriteKit
import SwiftUI

class LeafScene: SKScene {
    var onComplete: (([DivinationService.LeafType]) -> Void)?
    private var leaves: [DivinationService.LeafType] = []
    private var leafNodes: [(node: SKShapeNode, leaf: DivinationService.LeafType, settled: Bool)] = []
    private var windTimer: Timer?
    private var settlementCheckTimer: Timer?

    override func didMove(to view: SKView) {
        print("🍂 LeafScene didMove to view, size: \(size)")
        backgroundColor = .clear
        scaleMode = .resizeFill
        // 增加重力，让叶子更快落下
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        print("⚙️ Gravity set to: \(physicsWorld.gravity)")

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.friction = 0.5

        leaves = DivinationService.randomLeaves(count: 3)
        print("🍂 Selected leaves: \(leaves.map { $0.name })")
        print("📐 Scene frame: \(frame)")

        // 添加轻微的触觉反馈
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        dropLeaves()
    }

    private func dropLeaves() {
        for (index, leaf) in leaves.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.4) { [weak self] in
                self?.createLeafNode(leaf: leaf, index: index)
            }
        }

        // Start wind gusts
        windTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            self?.applyWindGust()
        }

        // Check for settlement
        settlementCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkSettlement()
        }
    }

    private func createLeafNode(leaf: DivinationService.LeafType, index: Int) {
        let path = leafPath(for: index)
        let node = SKShapeNode(path: path)

        // 直接从 hex 创建 UIColor
        let hex = leaf.colorHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255.0
        let g = CGFloat((int >> 8) & 0xFF) / 255.0
        let b = CGFloat(int & 0xFF) / 255.0
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)

        node.fillColor = color.withAlphaComponent(0.8)
        node.strokeColor = color.withAlphaComponent(0.4)
        node.lineWidth = 1
        node.zPosition = 10  // 确保叶子在最上层

        let xPos = size.width * CGFloat.random(in: 0.2...0.8)
        node.position = CGPoint(x: xPos, y: size.height + 30)

        print("🎨 Leaf color - R:\(r) G:\(g) B:\(b), fillColor: \(node.fillColor)")

        node.physicsBody = SKPhysicsBody(polygonFrom: path)
        node.physicsBody?.density = 1.0  // 增加密度，让叶子更重
        node.physicsBody?.linearDamping = 2.5  // 增加空气阻力
        node.physicsBody?.angularDamping = 2.0  // 增加旋转阻力
        node.physicsBody?.restitution = 0.3  // 略微增加弹性
        node.physicsBody?.mass = 0.5  // 设置质量

        addChild(node)
        leafNodes.append((node: node, leaf: leaf, settled: false))

        print("🍃 Created leaf node: \(leaf.name) at position \(node.position), color: \(color), alpha: \(node.alpha), zPosition: \(node.zPosition)")
    }

    private func leafPath(for index: Int) -> CGPath {
        let path = CGMutablePath()
        switch index % 3 {
        case 0: // Broad leaf (maple-like)
            path.move(to: CGPoint(x: 0, y: 15))
            path.addQuadCurve(to: CGPoint(x: 12, y: 5), control: CGPoint(x: 10, y: 14))
            path.addQuadCurve(to: CGPoint(x: 8, y: -10), control: CGPoint(x: 14, y: -2))
            path.addQuadCurve(to: CGPoint(x: 0, y: -15), control: CGPoint(x: 5, y: -14))
            path.addQuadCurve(to: CGPoint(x: -8, y: -10), control: CGPoint(x: -5, y: -14))
            path.addQuadCurve(to: CGPoint(x: -12, y: 5), control: CGPoint(x: -14, y: -2))
            path.addQuadCurve(to: CGPoint(x: 0, y: 15), control: CGPoint(x: -10, y: 14))
        case 1: // Elongated leaf (willow-like)
            path.move(to: CGPoint(x: 0, y: 18))
            path.addQuadCurve(to: CGPoint(x: 0, y: -18), control: CGPoint(x: 10, y: 0))
            path.addQuadCurve(to: CGPoint(x: 0, y: 18), control: CGPoint(x: -10, y: 0))
        case 2: // Round leaf (ginkgo-like)
            path.move(to: CGPoint(x: 0, y: -12))
            path.addCurve(to: CGPoint(x: 0, y: 12),
                         control1: CGPoint(x: 16, y: -8),
                         control2: CGPoint(x: 16, y: 8))
            path.addCurve(to: CGPoint(x: 0, y: -12),
                         control1: CGPoint(x: -16, y: 8),
                         control2: CGPoint(x: -16, y: -8))
        default:
            break
        }
        path.closeSubpath()
        return path
    }

    private func applyWindGust() {
        for (node, _, settled) in leafNodes where !settled {
            // 减小风力，避免吹飞叶子
            let force = CGVector(
                dx: CGFloat.random(in: -8...8),
                dy: CGFloat.random(in: -2...2)  // 减小垂直风力
            )
            node.physicsBody?.applyForce(force)
            node.physicsBody?.applyTorque(CGFloat.random(in: -0.3...0.3))
        }
    }

    private func checkSettlement() {
        let threshold: CGFloat = size.height * 0.25
        let velocityThreshold: CGFloat = 5

        var allSettled = true
        for i in leafNodes.indices {
            let node = leafNodes[i].node
            let vel = node.physicsBody?.velocity ?? .zero
            let speed = sqrt(vel.dx * vel.dx + vel.dy * vel.dy)

            print("🍃 Leaf \(i) - pos: \(node.position.y), speed: \(speed), threshold: \(threshold)")

            if node.position.y < threshold && speed < velocityThreshold {
                if !leafNodes[i].settled {
                    print("✅ Leaf \(i) settled")
                }
                leafNodes[i].settled = true
            } else {
                allSettled = false
            }
        }

        if allSettled && leafNodes.count == 3 {
            print("🎉 All leaves settled!")
            windTimer?.invalidate()
            windTimer = nil
            settlementCheckTimer?.invalidate()
            settlementCheckTimer = nil

            let selectedLeaves = leafNodes.map { $0.leaf }

            // 添加完成的触觉反馈
            DispatchQueue.main.async {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                print("📖 Calling onComplete")
                self?.onComplete?(selectedLeaves)
            }
        }
    }

    override func willMove(from view: SKView) {
        windTimer?.invalidate()
        settlementCheckTimer?.invalidate()
    }
}
