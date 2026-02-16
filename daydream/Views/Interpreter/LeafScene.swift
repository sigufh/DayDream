import SpriteKit
import SwiftUI

class LeafScene: SKScene {
    var onComplete: (([DivinationService.LeafType]) -> Void)?
    private var leaves: [DivinationService.LeafType] = []
    private var leafNodes: [(node: SKShapeNode, leaf: DivinationService.LeafType, settled: Bool)] = []
    private var windTimer: Timer?
    private var settlementCheckTimer: Timer?

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.5)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        leaves = DivinationService.randomLeaves(count: 3)
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
        let color = UIColor(Color(hex: leaf.colorHex))
        node.fillColor = color.withAlphaComponent(0.8)
        node.strokeColor = color.withAlphaComponent(0.4)
        node.lineWidth = 1

        let xPos = size.width * CGFloat.random(in: 0.2...0.8)
        node.position = CGPoint(x: xPos, y: size.height + 30)

        node.physicsBody = SKPhysicsBody(polygonFrom: path)
        node.physicsBody?.density = 0.3
        node.physicsBody?.linearDamping = 2.0
        node.physicsBody?.angularDamping = 1.5
        node.physicsBody?.restitution = 0.2

        addChild(node)
        leafNodes.append((node: node, leaf: leaf, settled: false))
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
            let force = CGVector(
                dx: CGFloat.random(in: -15...15),
                dy: CGFloat.random(in: -5...5)
            )
            node.physicsBody?.applyForce(force)
            node.physicsBody?.applyTorque(CGFloat.random(in: -0.5...0.5))
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

            if node.position.y < threshold && speed < velocityThreshold {
                leafNodes[i].settled = true
            } else {
                allSettled = false
            }
        }

        if allSettled && leafNodes.count == 3 {
            windTimer?.invalidate()
            windTimer = nil
            settlementCheckTimer?.invalidate()
            settlementCheckTimer = nil

            let selectedLeaves = leafNodes.map { $0.leaf }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.onComplete?(selectedLeaves)
            }
        }
    }

    override func willMove(from view: SKView) {
        windTimer?.invalidate()
        settlementCheckTimer?.invalidate()
    }
}
