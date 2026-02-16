import SwiftUI

struct DreamCardView: View {
    let dream: Dream

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Dream image
            if let imageData = dream.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 120, maxHeight: 200)
                    .clipped()
            } else {
                // Placeholder gradient based on emotion
                RoundedRectangle(cornerRadius: 0)
                    .fill(dream.emotion.linearGradient)
                    .frame(height: CGFloat(120 + abs(dream.id.hashValue % 80)))
                    .overlay {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 32))
                            .foregroundStyle(.white.opacity(0.6))
                    }
            }

            // Text content
            VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                // Emotion accent bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(dream.emotion.primaryColor)
                    .frame(width: 24, height: 3)

                if !dream.poem.isEmpty {
                    Text(dream.poem)
                        .font(.system(size: 13, weight: .light, design: .serif))
                        .foregroundStyle(Color.deepBlueGray)
                        .lineLimit(3)
                        .lineSpacing(4)
                }

                HStack {
                    Text(dream.emotion.displayName)
                        .font(.system(size: 10))
                        .foregroundStyle(dream.emotion.primaryColor)

                    Spacer()

                    Text(dream.createdAt.formatted(.dateTime.month().day()))
                        .font(.system(size: 10))
                        .foregroundStyle(Color.mistyBlue)
                }
            }
            .padding(DreamSpacing.md)
        }
        .background(Color.ivoryGray)
        .clipShape(RoundedRectangle(cornerRadius: DreamSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.06), radius: DreamSpacing.cardShadowRadius, x: 0, y: 2)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(Double(abs(dream.id.hashValue % 5)) * 0.08)) {
                appeared = true
            }
        }
    }
}
