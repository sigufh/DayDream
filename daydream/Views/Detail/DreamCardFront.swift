import SwiftUI

struct DreamCardFront: View {
    let dream: Dream

    var body: some View {
        ZStack {
            // Background image or gradient
            if let imageData = dream.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                dream.emotion.linearGradient
            }

            // Dark overlay for text readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Content
            VStack {
                Spacer()

                VStack(spacing: DreamSpacing.md) {
                    Text(dream.poem)
                        .font(.system(size: 18, weight: .light, design: .serif))
                        .foregroundStyle(.white)
                        .lineSpacing(10)
                        .tracking(1.5)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DreamSpacing.lg)
                }

                Spacer()
                    .frame(height: DreamSpacing.xxl)

                // Watermark area
                WatermarkOverlay(
                    locationName: dream.locationName,
                    weatherDescription: dream.weatherDescription,
                    temperature: dream.temperature,
                    date: dream.createdAt
                )
            }

            // Tap hint
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(DreamSpacing.md)
                }
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DreamSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
    }
}
