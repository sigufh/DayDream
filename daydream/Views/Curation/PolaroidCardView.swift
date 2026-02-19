import SwiftUI

struct PolaroidCardView: View {
    let imageData: Data?
    let poem: String
    let emotion: DreamEmotion
    let date: Date
    let weather: String?
    let showDate: Bool
    let showWeather: Bool

    private let cardWidth: CGFloat = 340
    private let imageHeight: CGFloat = 340
    private let bottomHeight: CGFloat = 140

    var body: some View {
        VStack(spacing: 0) {
            // Image area
            ZStack {
                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: cardWidth, height: imageHeight)
                        .clipped()
                } else {
                    emotion.linearGradient
                        .frame(width: cardWidth, height: imageHeight)
                }
            }

            // Bottom white area (polaroid frame)
            VStack(spacing: DreamSpacing.sm) {
                // Poem text
                Text(poem)
                    .font(.system(size: 13, weight: .light, design: .serif))
                    .foregroundStyle(Color.deepBlueGray.opacity(0.8))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, DreamSpacing.md)
                    .padding(.top, DreamSpacing.md)

                Spacer()

                // Watermarks
                HStack(spacing: 6) {
                    if showDate {
                        WatermarkLabel(
                            icon: "calendar",
                            text: date.formatted(date: .abbreviated, time: .omitted)
                        )
                    }

                    if showDate && showWeather {
                        Text("·")
                            .font(.system(size: 9))
                            .foregroundStyle(Color.mistyBlue.opacity(0.5))
                    }

                    if showWeather, let weather {
                        WatermarkLabel(
                            icon: "cloud.fill",
                            text: weather
                        )
                    }
                }
                .padding(.horizontal, DreamSpacing.sm)
                .padding(.bottom, DreamSpacing.md)
            }
            .frame(width: cardWidth, height: bottomHeight)
            .background(Color.pearlWhite)
        }
        .background(Color.pearlWhite)
        .cornerRadius(DreamSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: DreamSpacing.cardShadowRadius, x: 0, y: 4)
    }
}

extension PolaroidCardView {
    /// Render the polaroid card as a UIImage for export
    @MainActor
    func render() -> UIImage? {
        let totalHeight = imageHeight + bottomHeight + 32 // Extra padding
        let renderer = ImageRenderer(content: self)
        renderer.proposedSize = ProposedViewSize(width: cardWidth + 32, height: totalHeight)
        return renderer.uiImage
    }
}

private struct WatermarkLabel: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
            Text(text)
                .font(.system(size: 9, weight: .light))
        }
        .foregroundStyle(Color.mistyBlue)
    }
}
