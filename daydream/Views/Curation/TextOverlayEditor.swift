import SwiftUI

struct TextOverlayEditor: View {
    @Binding var text: String
    @Binding var position: CGSize
    @Binding var textScale: CGFloat

    @State private var lastPosition: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var isEditing = false

    var body: some View {
        Text(text)
            .font(.system(size: 16 * textScale, weight: .light, design: .serif))
            .foregroundStyle(.white)
            .lineSpacing(8)
            .multilineTextAlignment(.center)
            .padding(DreamSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.black.opacity(0.2))
                    .opacity(isEditing ? 1 : 0)
            )
            .scaleEffect(textScale)
            .offset(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        position = CGSize(
                            width: lastPosition.width + value.translation.width,
                            height: lastPosition.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        lastPosition = position
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        textScale = max(0.5, min(2.5, lastScale * value))
                    }
                    .onEnded { _ in
                        lastScale = textScale
                    }
            )
            .onTapGesture {
                isEditing.toggle()
            }
    }
}
