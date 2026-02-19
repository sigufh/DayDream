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
    @State private var transitionManager = TransitionManager()
    @State private var selectedTab = 0
    @Namespace private var transitionNamespace

    init() {
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

        ZStack {
            // ============================
            // 底层：TabView
            // ============================
            Group {
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

                // 录音键
                if selectedTab == 0 && transitionManager.currentPage == .gallery {
                    VStack {
                        Spacer()
                        LightOrbView {
                            transitionManager.startRecording()
                        }
                        .matchedGeometryEffect(
                            id: "recordingOrb",
                            in: transitionNamespace,
                            isSource: true
                        )
                        .padding(.bottom, DreamSpacing.orbBottomPadding)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .opacity(transitionManager.currentPage == .gallery ? 1 : 0)
            .allowsHitTesting(transitionManager.currentPage == .gallery)

            // ============================
            // 录音页面
            // ============================
            if transitionManager.currentPage == .capture {
                VoiceCaptureView(
                    namespace: transitionNamespace,
                    isVisible: true,
                    onComplete: {
                        transitionManager.completeRecording()
                    },
                    onDismiss: {
                        transitionManager.dismissToGallery()
                    }
                )
                .zIndex(1)
            }

            // ============================
            // 处理页面
            // ============================
            if transitionManager.currentPage == .processing {
                ProcessingView(
                    onComplete: {
                        transitionManager.completeProcessing()
                    },
                    onDismiss: {
                        transitionManager.dismissToGallery()
                    }
                )
                .zIndex(2)
            }

            // ============================
            // 策展页面
            // ============================
            if transitionManager.currentPage == .curation {
                CurationView(
                    onDismiss: {
                        transitionManager.finishCuration()
                    }
                )
                .zIndex(3)
            }

            // ============================
            // 最顶层：过渡遮罩
            // ============================
            switch transitionManager.overlay {
            case .none:
                EmptyView()

            case .captureToProcessing(let phase):
                CaptureToProcessingOverlay(phase: phase)
                    .zIndex(999)

            case .processingToCuration(let phase):
                ProcessingToCurationOverlay(phase: phase)
                    .zIndex(999)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
}
