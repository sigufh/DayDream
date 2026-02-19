import SwiftUI
import SwiftData

@Observable
final class InterpreterViewModel {
    var isLeavesFalling = false
    var isInterpreting = false
    var todayInterpretation: String = ""
    var latestResult: Divination?
    var showResult = false

    func triggerDivination() {
        guard !isLeavesFalling else { return }
        isLeavesFalling = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func completeDivination(leaves: [DivinationService.LeafType], dreams: [Dream], modelContext: ModelContext) async {
        isLeavesFalling = false
        isInterpreting = true
        defer { isInterpreting = false }

        let interpretation = await DivinationService.interpret(leaves: leaves, dreams: dreams)
        let leafNames = leaves.map { $0.name }
        let relatedDreamID = dreams.first?.id

        let divination = Divination(
            leaves: leafNames,
            interpretation: interpretation,
            relatedDreamID: relatedDreamID
        )

        modelContext.insert(divination)
        try? modelContext.save()

        latestResult = divination
        showResult = true
    }

    func generateInterpretation(for dream: Dream?) async {
        guard let dream else {
            todayInterpretation = ""
            return
        }

        isInterpreting = true
        defer { isInterpreting = false }

        todayInterpretation = await DivinationService.zhouGongInterpret(dream: dream)
    }
}
