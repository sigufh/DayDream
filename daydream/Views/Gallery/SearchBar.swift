import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: DreamSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.mistyBlue)

            TextField("搜索梦境内容、意象...", text: $text)
                .font(.system(size: 15))
                .foregroundStyle(Color.deepBlueGray)
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.mistyBlue)
                }
            }
        }
        .padding(.horizontal, DreamSpacing.md)
        .padding(.vertical, DreamSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ivoryGray)
        )
    }
}
