import SwiftUI

struct ImageEditorView: View {
    let imageData: Data?
    @Binding var imageOffset: CGSize
    @Binding var imageScale: CGFloat

    @State private var lastOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(imageScale)
                        .offset(imageOffset)
                        .gesture(dragGesture)
                        .gesture(magnificationGesture)
                }
            }
            .frame(width: geo.size.width, height: geo.size.width / DreamSpacing.detailCardAspectRatio)
            .clipShape(RoundedRectangle(cornerRadius: DreamSpacing.cardCornerRadius))
        }
        .aspectRatio(DreamSpacing.detailCardAspectRatio, contentMode: .fit)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                imageOffset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = imageOffset
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                imageScale = max(0.5, min(3.0, newScale))
            }
            .onEnded { _ in
                lastScale = imageScale
            }
    }
}
