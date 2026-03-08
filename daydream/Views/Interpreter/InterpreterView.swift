import SwiftUI
import SwiftData

struct InterpreterView: View {
    @State private var selectedTab = 0
    @State private var chatViewModel = InterpreterChatViewModel()

    var body: some View {
        ZStack {
            InterpreterBackground()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: DreamSpacing.sm) {
                    Text("说书人")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundStyle(.white)
                        .tracking(4)

                    Text("解梦问签，占卜未来")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.top, DreamSpacing.md)

                // 分段控件
                Picker("", selection: $selectedTab) {
                    Text("周公解梦").tag(0)
                    Text("六爻占卜").tag(1)
                    Text("塔罗牌").tag(2)
                    Text("记录").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DreamSpacing.md)
                .padding(.vertical, DreamSpacing.md)

                // 内容区域
                TabView(selection: $selectedTab) {
                    ZhouGongView(chatViewModel: chatViewModel)
                        .tag(0)

                    HexagramView(chatViewModel: chatViewModel)
                        .tag(1)

                    TarotView(chatViewModel: chatViewModel)
                        .tag(2)

                    HistoryView()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
