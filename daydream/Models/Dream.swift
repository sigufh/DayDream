import Foundation
import SwiftData

@Model
final class Dream {
    var id: UUID
    var createdAt: Date
    var transcript: String
    var poem: String
    var emotionRaw: String
    var imageData: Data?
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var weatherDescription: String?
    var temperature: Double?
    var reflectionQuestion: String?
    var worldName: String?
    var symbols: [String]

    var emotion: DreamEmotion {
        get { DreamEmotion(rawValue: emotionRaw) ?? .serenity }
        set { emotionRaw = newValue.rawValue }
    }

    init(
        transcript: String = "",
        poem: String = "",
        emotion: DreamEmotion = .serenity,
        imageData: Data? = nil,
        locationName: String? = nil,
        weatherDescription: String? = nil,
        temperature: Double? = nil,
        reflectionQuestion: String? = nil,
        worldName: String? = nil,
        symbols: [String] = []
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.transcript = transcript
        self.poem = poem
        self.emotionRaw = emotion.rawValue
        self.imageData = imageData
        self.locationName = locationName
        self.weatherDescription = weatherDescription
        self.temperature = temperature
        self.reflectionQuestion = reflectionQuestion
        self.worldName = worldName
        self.symbols = symbols
    }
}
