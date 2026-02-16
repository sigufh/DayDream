import SwiftUI

struct GradientBackground: View {
    var colors: [Color] = [.pearlWhite, .ivoryGray]
    var startPoint: UnitPoint = .top
    var endPoint: UnitPoint = .bottom

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
        .ignoresSafeArea()
    }
}

struct EmotionGradientBackground: View {
    let emotion: DreamEmotion

    var body: some View {
        LinearGradient(
            colors: emotion.gradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
