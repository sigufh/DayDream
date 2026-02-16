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

    func openCapture() {
        showingCapture = true
    }

    func finishCapture(transcript: String, emotion: DreamEmotion, audioURL: URL?) {
        capturedTranscript = transcript
        capturedEmotion = emotion
        capturedAudioURL = audioURL
        showingCapture = false
        showingProcessing = true
    }

    func finishProcessing(imageData: Data?, poem: String, reflection: String, worldName: String = "", symbols: [String] = []) {
        processedImageData = imageData
        processedPoem = poem
        processedReflection = reflection
        processedWorldName = worldName
        processedSymbols = symbols
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

    private func resetCaptureData() {
        capturedTranscript = ""
        capturedEmotion = .serenity
        capturedAudioURL = nil
        processedImageData = nil
        processedPoem = ""
        processedReflection = ""
        processedWorldName = ""
        processedSymbols = []
    }
}
