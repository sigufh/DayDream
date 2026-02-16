import SpriteKit
import SwiftUI

class ParticleScene: SKScene {
    var particleNodes: [SKShapeNode] = []
    var emotionColors: [UIColor] = DreamEmotion.allCases.map { UIColor($0.primaryColor) }
    var currentColorIndex: Int = 0

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
    }

    func createParticle(radius: CGFloat = 2, color: UIColor = .white) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: radius)
        node.fillColor = color
        node.strokeColor = .clear
        node.alpha = CGFloat.random(in: 0.3...0.8)
        node.glowWidth = 1
        return node
    }

    func currentEmotionColor() -> UIColor {
        emotionColors[currentColorIndex % emotionColors.count]
    }

    func cycleColor() {
        currentColorIndex += 1
    }
}
