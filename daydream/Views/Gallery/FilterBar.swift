import SwiftUI

struct FilterBar: View {
    @Binding var selectedEmotion: DreamEmotion?
    @Binding var showFavoritesOnly: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DreamSpacing.sm) {
                // 收藏筛选
                FilterChip(
                    icon: "heart.fill",
                    label: "收藏",
                    isSelected: showFavoritesOnly,
                    color: Color.auroraLavender
                ) {
                    showFavoritesOnly.toggle()
                }

                // 情绪筛选
                ForEach(DreamEmotion.allCases) { emotion in
                    FilterChip(
                        icon: nil,
                        label: emotion.displayName,
                        isSelected: selectedEmotion == emotion,
                        color: emotion.primaryColor
                    ) {
                        if selectedEmotion == emotion {
                            selectedEmotion = nil
                        } else {
                            selectedEmotion = emotion
                        }
                    }
                }
            }
        }
    }
}

private struct FilterChip: View {
    let icon: String?
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                }
                Text(label)
                    .font(.system(size: 12, weight: isSelected ? .medium : .regular))
            }
            .foregroundStyle(isSelected ? .white : Color.deepBlueGray)
            .padding(.horizontal, DreamSpacing.md)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.ivoryGray)
            )
        }
    }
}

struct EmptySearchResultView: View {
    var body: some View {
        VStack(spacing: DreamSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(Color.mistyBlue.opacity(0.5))

            Text("没有找到匹配的梦境")
                .font(.system(size: 16, weight: .light, design: .serif))
                .foregroundStyle(Color.deepBlueGray)

            Text("试试其他关键词或筛选条件")
                .font(.system(size: 13))
                .foregroundStyle(Color.mistyBlue)
        }
        .padding(.top, 100)
    }
}
