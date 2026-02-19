import SwiftUI

/// 全局过渡管理器 - 控制所有页面切换的无割裂动画
///
/// 核心原则：
/// - 遮罩在最上层，遮住一切
/// - 遮罩完全不透明时，在底层静默换页（无动画）
/// - 遮罩淡出，揭开新页面
@Observable
class TransitionManager {
    // MARK: - Page States
    enum Page: Equatable {
        case gallery
        case capture
        case processing
        case curation
    }

    /// 当前实际渲染的页面
    var currentPage: Page = .gallery

    // MARK: - Overlay States
    enum OverlayPhase: Equatable {
        case none
        /// 录音完成：圆球扩散全屏
        case captureToProcessing(phase: AnimPhase)
        /// 处理完成：浮光拓印
        case processingToCuration(phase: AnimPhase)
    }

    enum AnimPhase: Equatable {
        case expanding   // 遮罩展开中
        case covering    // 完全覆盖（换页窗口）
        case revealing   // 遮罩淡出中
    }

    var overlay: OverlayPhase = .none

    var isTransitioning: Bool { overlay != .none }

    // MARK: - Gallery → Capture

    func startRecording() {
        guard !isTransitioning else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            currentPage = .capture
        }
    }

    // MARK: - Capture → Processing（圆球扩散）

    func completeRecording() {
        guard !isTransitioning else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // Phase 1: 遮罩展开
        overlay = .captureToProcessing(phase: .expanding)

        // Phase 2: 遮罩完全覆盖，静默换页
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.overlay = .captureToProcessing(phase: .covering)
            // 无动画换页 —— 遮罩全屏不透明，用户看不见
            self.currentPage = .processing
        }

        // Phase 3: 遮罩淡出，揭开处理页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.overlay = .captureToProcessing(phase: .revealing)
        }

        // Phase 4: 清理
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.overlay = .none
        }
    }

    // MARK: - Processing → Curation（浮光拓印）

    func completeProcessing() {
        guard !isTransitioning else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Phase 1: 浮光拓印遮罩展开
        overlay = .processingToCuration(phase: .expanding)

        // Phase 2: 覆盖后换页
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.overlay = .processingToCuration(phase: .covering)
            self.currentPage = .curation
        }

        // Phase 3: 淡出
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.overlay = .processingToCuration(phase: .revealing)
        }

        // Phase 4: 清理
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.overlay = .none
        }
    }

    // MARK: - Dismiss

    func dismissToGallery() {
        withAnimation(.easeOut(duration: 0.4)) {
            currentPage = .gallery
            overlay = .none
        }
    }

    func finishCuration() {
        withAnimation(.easeOut(duration: 0.3)) {
            currentPage = .gallery
        }
    }
}
