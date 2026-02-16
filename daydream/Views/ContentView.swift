import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppRouter.self) private var router

    var body: some View {
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
}

struct MainContainerView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.galleryPath) {
            GalleryView()
                .navigationDestination(for: Dream.self) { dream in
                    DreamDetailView(dream: dream)
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
