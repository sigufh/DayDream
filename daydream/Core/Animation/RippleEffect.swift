import SpriteKit

class RippleEffect {
    static func emit(in scene: SKScene, at position: CGPoint, color: UIColor) {
        for i in 0..<3 {
            let ring = SKShapeNode(circleOfRadius: 10)
            ring.strokeColor = color
            ring.fillColor = .clear
            ring.lineWidth = 2
            ring.position = position
            ring.alpha = 0.8
            ring.zPosition = 100
            scene.addChild(ring)

            let delay = Double(i) * 0.15
            let expand = SKAction.scale(to: 8 + CGFloat(i) * 2, duration: 0.8)
            let fade = SKAction.fadeOut(withDuration: 0.8)
            let group = SKAction.group([expand, fade])
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                group,
                SKAction.removeFromParent()
            ])
            ring.run(sequence)
        }
    }
}
