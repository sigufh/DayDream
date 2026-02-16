import SpriteKit
import SwiftUI

class CaptureParticleScene: ParticleScene {
    private var sphereNode: SKShapeNode!
    private var orbitingParticles: [(node: SKShapeNode, baseRadius: CGFloat, angle: CGFloat, speed: CGFloat)] = []
    private var isSpeaking = false
    private var colorCycleTimer: TimeInterval = 0
    private var lockedColor: UIColor?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupSphere()
        setupOrbitingParticles()
    }

    private func setupSphere() {
        let radius: CGFloat = 40
        sphereNode = SKShapeNode(circleOfRadius: radius)
        sphereNode.fillColor = currentEmotionColor()
        sphereNode.strokeColor = .clear
        sphereNode.glowWidth = 8
        sphereNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sphereNode.alpha = 0.9
        sphereNode.zPosition = 10
        addChild(sphereNode)
    }

    private func setupOrbitingParticles() {
        let count = Int.random(in: 80...120)
        for _ in 0..<count {
            let baseRadius = CGFloat.random(in: 60...180)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 0.002...0.015)
            let particleSize = CGFloat.random(in: 1.5...4)

            let node = createParticle(radius: particleSize, color: currentEmotionColor().withAlphaComponent(0.6))
            let x = sphereNode.position.x + cos(angle) * baseRadius
            let y = sphereNode.position.y + sin(angle) * baseRadius
            node.position = CGPoint(x: x, y: y)
            addChild(node)

            orbitingParticles.append((node: node, baseRadius: baseRadius, angle: angle, speed: speed))
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard lockedColor == nil else { return }

        // Color cycling
        colorCycleTimer += 1.0 / 60
        if colorCycleTimer > 3.0 {
            colorCycleTimer = 0
            cycleColor()
            let newColor = currentEmotionColor()
            sphereNode.run(SKAction.customAction(withDuration: 0.5) { node, elapsed in
                (node as? SKShapeNode)?.fillColor = newColor
            })
        }

        // Update orbiting particles
        let center = sphereNode.position
        for i in orbitingParticles.indices {
            orbitingParticles[i].angle += orbitingParticles[i].speed

            // Adjust radius based on speech
            let targetRadius: CGFloat
            if isSpeaking {
                targetRadius = orbitingParticles[i].baseRadius * 0.4
            } else {
                targetRadius = orbitingParticles[i].baseRadius * 1.2
            }

            let currentRadius = orbitingParticles[i].node.position.distance(to: center)
            let newRadius = currentRadius + (targetRadius - currentRadius) * 0.03

            let angle = orbitingParticles[i].angle
            orbitingParticles[i].node.position = CGPoint(
                x: center.x + cos(angle) * newRadius,
                y: center.y + sin(angle) * newRadius
            )
        }
    }

    func updateSpeaking(_ speaking: Bool) {
        isSpeaking = speaking
    }

    func lockColor(emotion: DreamEmotion) {
        let color = UIColor(emotion.primaryColor)
        lockedColor = color
        sphereNode.fillColor = color

        for (particle, _, _, _) in orbitingParticles {
            particle.run(SKAction.customAction(withDuration: 0.5) { node, _ in
                (node as? SKShapeNode)?.fillColor = color.withAlphaComponent(0.6)
            })
        }

        RippleEffect.emit(in: self, at: sphereNode.position, color: color)

        // Brighten scene briefly
        let flash = SKShapeNode(rectOf: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.fillColor = color.withAlphaComponent(0.15)
        flash.strokeColor = .clear
        flash.zPosition = 50
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.8),
            SKAction.removeFromParent()
        ]))
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
