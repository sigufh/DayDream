import SwiftUI

@Observable
final class UserPreferences {
    static let shared = UserPreferences()

    var artStyle: ArtStyle {
        didSet {
            UserDefaults.standard.set(artStyle.rawValue, forKey: "artStyle")
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "artStyle"),
           let style = ArtStyle(rawValue: saved) {
            self.artStyle = style
        } else {
            self.artStyle = .impressionist // Default
        }
    }
}
