import SwiftUI

struct DreamDetailView: View {
    let dream: Dream
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()

            GeometryReader { geo in
                let cardWidth = geo.size.width - DreamSpacing.xl * 2
                let cardHeight = cardWidth / DreamSpacing.detailCardAspectRatio

                ZStack {
                    // Back face
                    DreamCardBack(dream: dream)
                        .frame(width: cardWidth, height: cardHeight)
                        .rotation3DEffect(
                            .degrees(isFlipped ? 0 : 180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .opacity(isFlipped ? 1 : 0)

                    // Front face
                    DreamCardFront(dream: dream)
                        .frame(width: cardWidth, height: cardHeight)
                        .rotation3DEffect(
                            .degrees(isFlipped ? -180 : 0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .opacity(isFlipped ? 0 : 1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    withAnimation(.spring(response: DreamSpacing.flipDuration, dampingFraction: 0.8)) {
                        isFlipped.toggle()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
