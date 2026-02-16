import SwiftUI
import SpriteKit

struct FallingLeavesOverlay: View {
    let onComplete: ([DivinationService.LeafType]) -> Void

    @State private var scene: LeafScene = {
        let scene = LeafScene()
        scene.backgroundColor = .clear
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: configuredScene(size: geo.size), options: [.allowsTransparency])
                .ignoresSafeArea()
        }
        .onAppear {
            scene.onComplete = onComplete
        }
    }

    private func configuredScene(size: CGSize) -> LeafScene {
        scene.size = size
        return scene
    }
}
