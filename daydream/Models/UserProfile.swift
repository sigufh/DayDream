import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var authProvider: String
    var hasCompletedOnboarding: Bool
    var createdAt: Date

    init(
        displayName: String = "",
        authProvider: String = "anonymous",
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.authProvider = authProvider
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = Date()
    }
}
