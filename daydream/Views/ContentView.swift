import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppRouter.self) private var router

    var body: some View {
        Group {
            switch appState.currentFlow {
            case .splash:
                SplashView()
            case .login:
                LoginView()
            case .onboarding:
                OnboardingView()
            case .main:
                MainContainerView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.currentFlow)
    }
}

struct MainContainerView: View {
    @Environment(AppRouter.self) private var router
    @State private var selectedTab = 0

    init() {
        // Style the tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.pearlWhite)
        appearance.shadowColor = UIColor(Color.linen)

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor(Color.mistyBlue)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor(Color.deepBlueGray)
        ]

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.mistyBlue)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.auroraLavender)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        @Bindable var router = router

        TabView(selection: $selectedTab) {
            Tab("梦境回廊", systemImage: "moon.stars.fill", value: 0) {
                NavigationStack(path: $router.galleryPath) {
                    GalleryView()
                        .navigationDestination(for: Dream.self) { dream in
                            DreamDetailView(dream: dream)
                        }
                }
            }

            Tab("历流年", systemImage: "circle.hexagongrid.fill", value: 1) {
                NavigationStack {
                    ChroniclesView()
                }
            }

            Tab("说书人", systemImage: "leaf.fill", value: 2) {
                NavigationStack {
                    InterpreterView()
                }
            }
        }
        .fullScreenCover(isPresented: $router.showingCapture) {
            VoiceCaptureView()
        }
        .fullScreenCover(isPresented: $router.showingProcessing) {
            ProcessingView()
        }
        .fullScreenCover(isPresented: $router.showingCuration) {
            CurationView()
        }
    }
}
