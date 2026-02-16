import SwiftUI

struct TypewriterText: View {
    let fullText: String
    let trigger: Bool
    var speed: Double = 0.05

    @State private var displayedText = ""
    @State private var typewriterTask: Task<Void, Never>?

    var body: some View {
        Text(displayedText)
            .onChange(of: trigger) { _, newValue in
                typewriterTask?.cancel()
                if newValue {
                    startTyping()
                } else {
                    displayedText = ""
                }
            }
            .onAppear {
                if trigger {
                    startTyping()
                }
            }
            .onDisappear {
                typewriterTask?.cancel()
            }
    }

    private func startTyping() {
        displayedText = ""
        let characters = Array(fullText)
        let interval = speed
        typewriterTask = Task {
            for char in characters {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { return }
                displayedText.append(char)
            }
        }
    }
}
