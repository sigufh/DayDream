import SwiftUI
import SwiftData

@main
struct daydreamApp: App {
    @State private var appState = AppState()
    @State private var router = AppRouter()

    // Shared model container for app and widgets
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Dream.self, UserProfile.self, Divination.self])

        // Try to use app group for shared data access (required for widgets)
        // If not configured, fall back to default location
        let appGroupID = "group.com.xiaotian.daydream"

        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            // App group is configured - use shared location
            let storeURL = appGroupURL.appendingPathComponent("daydream.sqlite")
            let config = ModelConfiguration(url: storeURL)

            do {
                print("✓ Using App Group container for data sharing with widgets")
                return try ModelContainer(for: schema, configurations: config)
            } catch {
                fatalError("Failed to create ModelContainer with App Group: \(error)")
            }
        } else {
            // App group not configured - use default location
            // Widgets will not work until App Groups are configured
            print("⚠️ App Group not configured. Using default storage location.")
            print("   Widgets will not work until you configure App Groups in project settings.")

            do {
                return try ModelContainer(for: schema)
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(router)
        }
        .modelContainer(sharedModelContainer)
    }
}
