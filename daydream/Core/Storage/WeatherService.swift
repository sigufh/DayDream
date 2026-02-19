import CoreLocation

@Observable
final class WeatherService {
    var weatherDescription: String?
    var temperature: Double?

    func fetchWeather(for location: CLLocation?) async {
        guard let location else {
            applyFallback()
            return
        }

        do {
            try await fetchFromOpenMeteo(latitude: location.coordinate.latitude,
                                         longitude: location.coordinate.longitude)
        } catch is CancellationError {
            // Task cancelled (view lifecycle), not a real failure
        } catch let urlError as URLError where urlError.code == .cancelled {
            // URLSession request cancelled due to task cancellation
        } catch {
            print("Weather fetch failed, using fallback: \(error)")
            applyFallback()
        }
    }

    private func fetchFromOpenMeteo(latitude: Double, longitude: Double) async throws {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code&timezone=auto"

        guard let url = URL(string: urlString) else { return }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0, message: "Open-Meteo request failed")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let current = json["current"] as? [String: Any] else {
            throw APIError.decodingError("Failed to parse Open-Meteo response")
        }

        if let temp = current["temperature_2m"] as? Double {
            temperature = temp
        }

        if let code = current["weather_code"] as? Int {
            weatherDescription = mapWeatherCode(code)
        }
    }

    private func mapWeatherCode(_ code: Int) -> String {
        switch code {
        case 0:         return "晴"
        case 1:         return "晴间多云"
        case 2:         return "多云"
        case 3:         return "阴"
        case 45, 48:    return "雾"
        case 51:        return "小毛毛雨"
        case 53:        return "毛毛雨"
        case 55:        return "密毛毛雨"
        case 56, 57:    return "冻毛毛雨"
        case 61:        return "小雨"
        case 63:        return "中雨"
        case 65:        return "大雨"
        case 66, 67:    return "冻雨"
        case 71:        return "小雪"
        case 73:        return "中雪"
        case 75:        return "大雪"
        case 77:        return "雪粒"
        case 80:        return "小阵雨"
        case 81:        return "阵雨"
        case 82:        return "强阵雨"
        case 85:        return "小阵雪"
        case 86:        return "大阵雪"
        case 95:        return "雷暴"
        case 96:        return "雷暴伴冰雹"
        case 99:        return "强雷暴伴冰雹"
        default:        return "多云"
        }
    }

    private func applyFallback() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<8:     weatherDescription = "晨光"
        case 8..<17:    weatherDescription = "日间"
        case 17..<20:   weatherDescription = "黄昏"
        default:        weatherDescription = "星空"
        }
        temperature = nil
    }
}
