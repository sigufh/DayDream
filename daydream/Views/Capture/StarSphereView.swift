import SwiftUI
import SpriteKit

struct StarSphereView: View {
    let scene: CaptureParticleScene
    let onTapSphere: () -> Void

    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: configuredScene(size: geo.size), options: [.allowsTransparency])
                .ignoresSafeArea()
                .onTapGesture(coordinateSpace: .local) { location in
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    let distance = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
                    if distance < 60 {
                        onTapSphere()
                    }
                }
        }
    }

    private func configuredScene(size: CGSize) -> CaptureParticleScene {
        scene.size = size
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }
}
