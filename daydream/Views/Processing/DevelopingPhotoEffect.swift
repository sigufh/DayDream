import SwiftUI

struct DevelopingPhotoEffect: View {
    let imageData: Data?
    let poem: String
    let emotion: DreamEmotion
    @Binding var isRevealed: Bool

    @State private var imageBlur: CGFloat = 20
    @State private var imageOpacity: Double = 0
    @State private var poemOpacity: Double = 0
    @State private var watermarkOpacity: Double = 0

    var body: some View {
        VStack(spacing: DreamSpacing.lg) {
            // Image frame
            ZStack {
                RoundedRectangle(cornerRadius: DreamSpacing.cardCornerRadius)
                    .fill(emotion.linearGradient)
                    .frame(height: 300)

                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: DreamSpacing.cardCornerRadius))
                        .blur(radius: imageBlur)
                        .opacity(imageOpacity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: DreamSpacing.cardCornerRadius))

            // Poem with typewriter
            if poemOpacity > 0 {
                TypewriterText(fullText: poem, trigger: poemOpacity > 0, speed: 0.06)
                    .font(.system(size: 16, weight: .light, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DreamSpacing.xl)
                    .opacity(poemOpacity)
            }
        }
        .onChange(of: isRevealed) { _, revealed in
            if revealed {
                startReveal()
            }
        }
    }

    private func startReveal() {
        // Image fades in blurred
        withAnimation(.easeIn(duration: 0.5)) {
            imageOpacity = 1
        }
        // Image sharpens
        withAnimation(.easeInOut(duration: 2.0).delay(0.5)) {
            imageBlur = 0
        }
        // Poem appears
        withAnimation(.easeIn(duration: 0.5).delay(2.0)) {
            poemOpacity = 1
        }
        // Watermark fades in
        withAnimation(.easeIn(duration: 0.5).delay(3.0)) {
            watermarkOpacity = 1
        }
    }
}
