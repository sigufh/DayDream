import SwiftUI

struct DreamLoadingView: View {
    let emotion: DreamEmotion

    @State private var particles: [LoadingParticle] = []
    @State private var breathe = false
    @State private var textOpacity: Double = 0.4
    @State private var shimmerOffset: CGFloat = -200
    @State private var timer: Timer?

    private let particleCount = 30

    var body: some View {
        ZStack {
            // Breathing gradient background
            RadialGradient(
                colors: [
                    emotion.primaryColor.opacity(breathe ? 0.15 : 0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: breathe ? 40 : 20,
                endRadius: breathe ? 250 : 180
            )
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: breathe)

            // Floating particles
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x - particle.size / 2,
                        y: particle.y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )
                    context.opacity = particle.opacity
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(particle.color)
                    )
                    // Soft glow around larger particles
                    if particle.size > 3 {
                        let glowRect = rect.insetBy(dx: -particle.size, dy: -particle.size)
                        context.opacity = particle.opacity * 0.3
                        context.fill(
                            Circle().path(in: glowRect),
                            with: .color(particle.color)
                        )
                    }
                }
            }
            .ignoresSafeArea()

            // Center content
            VStack(spacing: DreamSpacing.lg) {
                // Pulsing orb cluster
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            emotion.primaryColor.opacity(breathe ? 0.3 : 0.1),
                            lineWidth: 0.5
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(breathe ? 1.2 : 0.9)

                    // Middle ring
                    Circle()
                        .stroke(
                            Color.auroraLavender.opacity(breathe ? 0.2 : 0.1),
                            lineWidth: 0.5
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(breathe ? 0.9 : 1.1)

                    // Core glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    emotion.primaryColor.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 20
                            )
                        )
                        .frame(width: 40, height: 40)
                        .scaleEffect(breathe ? 1.1 : 0.85)

                    // Bright center dot
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 6, height: 6)
                        .blur(radius: 2)
                }
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: breathe)

                // Animated text
                Text("浮光拓印中")
                    .font(.system(size: 16, weight: .light, design: .serif))
                    .foregroundStyle(.white.opacity(textOpacity))
                    .tracking(4)
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: textOpacity
                    )
                    .overlay(
                        // Shimmer effect
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.15), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 60)
                            .offset(x: shimmerOffset)
                            .animation(
                                .linear(duration: 3).repeatForever(autoreverses: false),
                                value: shimmerOffset
                            )
                    )
                    .clipped()
            }
        }
        .onAppear {
            generateParticles()
            startParticleAnimation()
            breathe = true
            textOpacity = 0.8
            shimmerOffset = 200
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func generateParticles() {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        let colors = emotion.gradient + [Color.auroraLavender, Color.white]

        particles = (0..<particleCount).map { _ in
            LoadingParticle(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight),
                size: CGFloat.random(in: 1.5...5),
                opacity: Double.random(in: 0.1...0.5),
                color: colors.randomElement() ?? .white,
                speedX: CGFloat.random(in: -0.3...0.3),
                speedY: CGFloat.random(in: -0.8...(-0.2)),
                drift: CGFloat.random(in: -0.5...0.5),
                phase: Double.random(in: 0...(2 * .pi))
            )
        }
    }

    private func startParticleAnimation() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30, repeats: true) { _ in
            for i in particles.indices {
                // Float upward with gentle drift
                particles[i].y += particles[i].speedY
                particles[i].x += particles[i].speedX + sin(particles[i].phase) * particles[i].drift * 0.1
                particles[i].phase += 0.02

                // Pulse opacity
                let opacityWave = sin(particles[i].phase * 2) * 0.15
                particles[i].opacity = max(0.05, min(0.6, particles[i].opacity + opacityWave * 0.01))

                // Respawn at bottom when particle floats off top
                if particles[i].y < -10 {
                    particles[i].y = screenHeight + 10
                    particles[i].x = CGFloat.random(in: 0...screenWidth)
                    particles[i].opacity = Double.random(in: 0.1...0.4)
                }
            }
        }
    }
}

private struct LoadingParticle {
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var color: Color
    var speedX: CGFloat
    var speedY: CGFloat
    var drift: CGFloat
    var phase: Double
}
