import SwiftUI
import SwiftData

@Observable
final class InterpreterViewModel {
    var isLeavesFalling = false
    var isInterpreting = false
    var todayInterpretation: String = ""
    var latestResult: Divination?
    var showResult = false
    var shakeDetected = false
    var currentDivination: Divination?  // 当前显示的占卜结果

    func triggerDivination() {
        guard !isLeavesFalling && !isInterpreting else { return }

        // 清除之前的结果
        currentDivination = nil

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()

        // 视觉反馈动画
        shakeDetected = true

        // 延迟启动落叶动画，让用户看到摇动反馈
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
            shakeDetected = false
            isLeavesFalling = true
        }
    }

    func completeDivination(yaos: [DivinationService.YaoType], dreams: [Dream], modelContext: ModelContext) async {
        isLeavesFalling = false
        isInterpreting = true
        defer { isInterpreting = false }

        // 查询本卦
        let hexagram = DivinationService.lookupHexagram(yaos: yaos)

        // 获取变卦（如有）
        let transformedHex = hexagram.transformedHexagram
        let movingYaos = hexagram.movingYaos

        // 获取解读
        let interpretation = await DivinationService.interpretHexagram(hexagram: hexagram, dreams: dreams)

        let yaoNames = yaos.map { $0.rawValue }
        let relatedDreamID = dreams.first?.id

        let divination = Divination(
            leaves: yaoNames,
            hexagramName: hexagram.name,
            hexagramMeaning: hexagram.meaning,
            transformedHexagramName: transformedHex?.name,
            transformedHexagramMeaning: transformedHex?.meaning,
            movingYaoIndices: movingYaos,
            interpretation: interpretation,
            relatedDreamID: relatedDreamID
        )

        modelContext.insert(divination)
        try? modelContext.save()

        latestResult = divination
        currentDivination = divination  // 设置当前显示的结果
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
