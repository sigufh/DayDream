import SwiftUI

enum AppFlow {
    case splash
    case login
    case onboarding
    case main
}

@Observable
final class AppState {
    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }
    var showSplash: Bool = true
    var currentFlow: AppFlow = .splash

    func finishSplash() {
        showSplash = false
        if !hasCompletedOnboarding {
            currentFlow = .onboarding
        } else {
            currentFlow = .main
        }
    }

    func finishOnboarding() {
        hasCompletedOnboarding = true
        currentFlow = .main
    }

    func signOut() {
        isAuthenticated = false
        currentFlow = .login
    }
}
