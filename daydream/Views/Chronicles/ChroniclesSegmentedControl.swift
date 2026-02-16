import SwiftUI

struct ChroniclesSegmentedControl: View {
    @Binding var selectedTab: Int
    let titles = ["情绪光谱", "梦境世界"]
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(titles.indices, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedTab = index
                    }
                } label: {
                    Text(titles[index])
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .tracking(1)
                        .foregroundStyle(selectedTab == index ? Color.deepBlueGray : Color.mistyBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DreamSpacing.sm + 2)
                        .background {
                            if selectedTab == index {
                                Capsule()
                                    .fill(Color.auroraLavender.opacity(0.4))
                                    .matchedGeometryEffect(id: "segment", in: namespace)
                            }
                        }
                }
            }
        }
        .padding(3)
        .background(
            Capsule()
                .fill(Color.ivoryGray)
        )
        .padding(.horizontal, DreamSpacing.xl)
    }
}
