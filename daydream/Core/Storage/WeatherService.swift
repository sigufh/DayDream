import CoreLocation

@Observable
final class WeatherService {
    var weatherDescription: String?
    var temperature: Double?

    func fetchWeather(for location: CLLocation?) async {
        // Stub: return mock weather data
        // In production, integrate with WeatherKit
        try? await Task.sleep(for: .seconds(0.5))

        let descriptions = ["晴", "多云", "微风", "薄雾", "细雨", "星空"]
        weatherDescription = descriptions.randomElement()
        temperature = Double.random(in: 5...30)
    }
}
