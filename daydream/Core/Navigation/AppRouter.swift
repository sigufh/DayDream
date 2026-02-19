import SwiftUI

@Observable
final class AppRouter {
    var galleryPath = NavigationPath()
    var showingCapture = false
    var showingProcessing = false
    var showingCuration = false
    var selectedDream: Dream?

    // Data passed between capture → processing → curation
    var capturedTranscript: String = ""
    var capturedEmotion: DreamEmotion = .serenity
    var capturedAudioURL: URL?

    // Data passed from processing → curation
    var processedImageData: Data?
    var processedPoem: String = ""
    var processedReflection: String = ""
    var processedWorldName: String = ""
    var processedSymbols: [String] = []
    var processedLocation: String?
    var processedWeather: String?

    func openCapture() {
        showingCapture = true
    }

    func finishCapture(transcript: String, emotion: DreamEmotion?, audioURL: URL?) {
        capturedTranscript = transcript
        // 如果没有指定情绪，使用默认值（AI 会在 ProcessingView 中判断）
        capturedEmotion = emotion ?? .serenity
        capturedAudioURL = audioURL
        showingCapture = false
        showingProcessing = true
    }

    func finishProcessing(imageData: Data?, poem: String, reflection: String, worldName: String = "", symbols: [String] = [], location: String? = nil, weather: String? = nil) {
        processedImageData = imageData
        processedPoem = poem
        processedReflection = reflection
        processedWorldName = worldName
        processedSymbols = symbols
        processedLocation = location
        processedWeather = weather
        showingProcessing = false
        showingCuration = true
    }

    func finishCuration() {
        showingCuration = false
        resetCaptureData()
    }

    func dismissToGallery() {
        showingCapture = false
        showingProcessing = false
        showingCuration = false
        resetCaptureData()
    }

    func resetCaptureData() {
        capturedTranscript = ""
        capturedEmotion = .serenity
        capturedAudioURL = nil
        processedImageData = nil
        processedPoem = ""
        processedReflection = ""
        processedWorldName = ""
        processedSymbols = []
        processedLocation = nil
        processedWeather = nil
    }
}
