import SwiftUI

// MARK: - Typography View Modifiers

struct DreamTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 28, weight: .light, design: .serif))
            .foregroundStyle(Color.deepBlueGray)
            .tracking(2)
    }
}

struct DreamBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .regular, design: .default))
            .foregroundStyle(Color.smokyGray)
            .lineSpacing(6)
    }
}

struct DreamCaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12, weight: .regular, design: .default))
            .foregroundStyle(Color.mistyBlue)
    }
}

struct DreamPoetryStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .light, design: .serif))
            .foregroundStyle(Color.deepBlueGray)
            .lineSpacing(10)
            .tracking(1.5)
    }
}

struct DreamHeadlineStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .medium, design: .serif))
            .foregroundStyle(Color.deepBlueGray)
            .tracking(1)
    }
}

// MARK: - View Extensions

extension View {
    func dreamTitle() -> some View { modifier(DreamTitleStyle()) }
    func dreamBody() -> some View { modifier(DreamBodyStyle()) }
    func dreamCaption() -> some View { modifier(DreamCaptionStyle()) }
    func dreamPoetry() -> some View { modifier(DreamPoetryStyle()) }
    func dreamHeadline() -> some View { modifier(DreamHeadlineStyle()) }
}
