import SwiftUI

struct InterpreterBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "1A1040"),
                Color(hex: "4527A0"),
                Color(hex: "311B92"),
                Color(hex: "1A1040"),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
