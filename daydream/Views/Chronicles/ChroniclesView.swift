import SwiftUI
import SwiftData

struct ChroniclesView: View {
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()

            VStack(spacing: DreamSpacing.md) {
                ChroniclesSegmentedControl(selectedTab: $selectedTab)
                    .padding(.top, DreamSpacing.sm)

                TabView(selection: $selectedTab) {
                    EmotionStatisticsView(dreams: dreams)
                        .tag(0)

                    DreamWorldMapView(dreams: dreams)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .navigationTitle("历流年")
        .navigationBarTitleDisplayMode(.inline)
    }
}
