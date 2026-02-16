import SwiftUI
import SwiftData

@main
struct daydreamApp: App {
    @State private var appState = AppState()
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(router)
        }
        .modelContainer(for: [Dream.self, UserProfile.self, Divination.self])
    }
}
