import SwiftUI

struct LightOrbView: View {
    let onActivate: () -> Void

    @State private var isPulsing = true
    @State private var isPressed = false
    @State private var particles: [OrbParticle] = []
    @State private var longPressCompleted = false
    @State private var animationTimer: Timer?

    var body: some View {
        ZStack {
            // Particle layer
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                for particle in particles {
                    let x = center.x + cos(particle.angle) * particle.radius
                    let y = center.y + sin(particle.angle) * particle.radius
                    let rect = CGRect(
                        x: x - particle.size / 2,
                        y: y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(Color.auroraLavender.opacity(particle.opacity))
                    )
                }
            }
            .frame(width: DreamSpacing.orbSize * 3, height: DreamSpacing.orbSize * 3)

            // Core orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.auroraLavender.opacity(0.8),
                            Color.auroraLavender.opacity(0.3),
                            Color.auroraLavender.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: DreamSpacing.orbSize / 2
                    )
                )
                .frame(width: DreamSpacing.orbSize, height: DreamSpacing.orbSize)
                .scaleEffect(isPulsing ? 1.0 : 0.9)
                .opacity(isPulsing ? 0.9 : 0.6)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: isPulsing
                )

            // Inner bright core
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 20, height: 20)
                .blur(radius: 4)
        }
        .onAppear {
            isPulsing = true
            generateParticles()
            animateParticles()
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
        .onLongPressGesture(minimumDuration: DreamSpacing.longPressDuration) {
            longPressCompleted = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            emitBurstParticles()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onActivate()
            }
        } onPressingChanged: { pressing in
            isPressed = pressing
            if pressing {
                withAnimation(.easeIn(duration: 0.3)) {
                    // visual feedback during press
                }
            }
        }
    }

    private func generateParticles() {
        particles = (0..<20).map { _ in
            OrbParticle(
                angle: Double.random(in: 0...(2 * .pi)),
                radius: CGFloat.random(in: 30...60),
                size: CGFloat.random(in: 2...5),
                opacity: Double.random(in: 0.2...0.6),
                speed: Double.random(in: 0.005...0.02)
            )
        }
    }

    private func animateParticles() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30, repeats: true) { _ in
            for i in particles.indices {
                particles[i].angle += particles[i].speed
            }
        }
    }

    private func emitBurstParticles() {
        withAnimation(.easeOut(duration: 0.4)) {
            for i in particles.indices {
                particles[i].radius += 40
                particles[i].opacity *= 0.3
            }
        }
    }
}

struct OrbParticle: Identifiable {
    let id = UUID()
    var angle: Double
    var radius: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: Double
}
