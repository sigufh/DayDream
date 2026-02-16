import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var appState
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.6
    @State private var ringOpacity: Double = 0
    @State private var fadeOut: Bool = false

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()

            VStack {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.382 - 40)

                ZStack {
                    // Aurora glow ring
                    Circle()
                        .stroke(Color.auroraLavender.opacity(0.5), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                        .blur(radius: 4)

                    Circle()
                        .stroke(Color.auroraLavender.opacity(0.3), lineWidth: 1)
                        .frame(width: 150, height: 150)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity * 0.6)
                        .blur(radius: 8)

                    // Logo text
                    VStack(spacing: 8) {
                        Text("浮光梦境")
                            .font(.system(size: 32, weight: .light, design: .serif))
                            .foregroundStyle(Color.deepBlueGray)
                            .tracking(6)

                        Text("DayDream")
                            .font(.system(size: 14, weight: .light, design: .default))
                            .foregroundStyle(Color.mistyBlue)
                            .tracking(4)
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                Spacer()
            }
        }
        .opacity(fadeOut ? 0 : 1)
        .onAppear {
            // Scale up with spring
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            // Ring expands
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                ringScale = 1.2
                ringOpacity = 1.0
            }
            // Hold, then fade out and transition
            DispatchQueue.main.asyncAfter(deadline: .now() + DreamSpacing.splashHoldDuration + 0.8) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    fadeOut = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    appState.finishSplash()
                }
            }
        }
    }
}
