import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.pearlWhite.ignoresSafeArea()
            VStack(spacing: DreamSpacing.lg) {
                Text("登录")
                    .dreamTitle()
                Button("跳过登录") {
                    appState.finishSplash()
                }
                .foregroundStyle(Color.auroraLavender)
            }
        }
    }
}
