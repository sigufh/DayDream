import SwiftUI

/// 情绪星球 - 带粒子特效和颜色变换
struct EmotionPlanetView: View {
    let isSpeaking: Bool
    let onTap: () -> Void

    @State private var currentEmotion: DreamEmotion = .serenity
    @State private var particles: [PlanetParticle] = []
    @State private var colorChangeTimer: Timer?
    @State private var animationTimer: Timer?
    @State private var ripples: [Ripple] = []
    @State private var brightness: CGFloat = 0
    /// 引用类型，让 Timer 闭包能读到最新值
    @State private var speakingRef = SpeakingRef()

    private let planetSize: CGFloat = 120
    private let particleCount = 30

    var body: some View {
        ZStack {
            // 背景亮度效果（点击时）
            Color.white
                .opacity(brightness)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // 粒子和涟漪绘制在固定区域内，以星球为圆心
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                // 绘制粒子（相对于中心的偏移）
                for particle in particles {
                    let x = center.x + particle.offsetX
                    let y = center.y + particle.offsetY
                    let rect = CGRect(
                        x: x - particle.size / 2,
                        y: y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(currentEmotion.primaryColor.opacity(particle.opacity))
                    )
                }

                // 绘制涟漪
                for ripple in ripples {
                    let ripplePath = Circle()
                        .path(in: CGRect(
                            x: center.x - ripple.radius,
                            y: center.y - ripple.radius,
                            width: ripple.radius * 2,
                            height: ripple.radius * 2
                        ))
                    context.stroke(
                        ripplePath,
                        with: .color(currentEmotion.primaryColor.opacity(ripple.opacity)),
                        lineWidth: 2
                    )
                }
            }
            .frame(width: planetSize * 5, height: planetSize * 5)
            .allowsHitTesting(false)

            // 中心星球
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            currentEmotion.primaryColor.opacity(0.8),
                            currentEmotion.primaryColor,
                            currentEmotion.primaryColor.opacity(0.6)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: planetSize / 2
                    )
                )
                .frame(width: planetSize, height: planetSize)
                .overlay {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: planetSize / 3
                            )
                        )
                }
                .shadow(color: currentEmotion.primaryColor.opacity(0.5), radius: 20)
                .onTapGesture {
                    createRipples()
                    onTap()
                }
        }
        .onAppear {
            speakingRef.value = isSpeaking
            generateParticles()
            startAnimationLoop()
            startColorChange()
        }
        .onDisappear {
            colorChangeTimer?.invalidate()
            colorChangeTimer = nil
            animationTimer?.invalidate()
            animationTimer = nil
        }
        .onChange(of: isSpeaking) { _, newValue in
            speakingRef.value = newValue
        }
    }

    // MARK: - Particles

    private func generateParticles() {
        particles = (0..<particleCount).map { index in
            let angle = Double(index) * (2 * .pi / Double(particleCount))
            let distance = CGFloat.random(in: 100...200)
            return PlanetParticle(
                offsetX: cos(angle) * distance,
                offsetY: sin(angle) * distance,
                baseAngle: angle,
                baseDistance: distance,
                currentDistance: distance,
                size: CGFloat.random(in: 3...6),
                opacity: Double.random(in: 0.4...0.8),
                speed: Double.random(in: 0.01...0.03)
            )
        }
    }

    private func startAnimationLoop() {
        animationTimer?.invalidate()
        let ref = speakingRef // 捕获引用类型，Timer 闭包里永远读最新值
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { _ in
            let speaking = ref.value
            for i in particles.indices {
                particles[i].baseAngle += particles[i].speed

                let targetDist = speaking ? 70.0 : particles[i].baseDistance
                particles[i].currentDistance += (targetDist - particles[i].currentDistance) * 0.08

                let dist = particles[i].currentDistance
                particles[i].offsetX = cos(particles[i].baseAngle) * dist
                particles[i].offsetY = sin(particles[i].baseAngle) * dist
            }
        }
    }

    // MARK: - Color

    private func startColorChange() {
        colorChangeTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                currentEmotion = DreamEmotion.allCases.randomElement() ?? .serenity
            }
        }
    }

    // MARK: - Ripples

    private func createRipples() {
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                ripples.append(Ripple(radius: 0, opacity: 0.8))
            }
        }

        withAnimation(.easeOut(duration: 1.5)) {
            for i in ripples.indices {
                ripples[i].radius = planetSize * 2 + CGFloat(i) * 20
                ripples[i].opacity = 0
            }
        }

        withAnimation(.easeOut(duration: 0.8)) {
            brightness = 0.3
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            ripples.removeAll()
        }
    }
}

// MARK: - Models

/// 引用类型包装，让 Timer 闭包能读取最新的 isSpeaking 值
private class SpeakingRef {
    var value: Bool = false
}

struct PlanetParticle {
    var offsetX: CGFloat
    var offsetY: CGFloat
    var baseAngle: Double
    let baseDistance: CGFloat
    var currentDistance: CGFloat
    let size: CGFloat
    let opacity: Double
    let speed: Double
}

struct Ripple {
    var radius: CGFloat
    var opacity: Double
}
