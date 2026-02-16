import SwiftUI

struct WatermarkOverlay: View {
    var locationName: String?
    var weatherDescription: String?
    var temperature: Double?
    var date: Date = Date()
    var showDate: Bool = true
    var showLocation: Bool = true
    var showWeather: Bool = true

    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    if showDate {
                        Text(date.formatted(.dateTime.year().month().day()))
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                    if showLocation, let location = locationName {
                        HStack(spacing: 2) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 8))
                            Text(location)
                                .font(.system(size: 10, weight: .light))
                        }
                        .foregroundStyle(Color.white.opacity(0.7))
                    }
                }

                Spacer()

                if showWeather {
                    VStack(alignment: .trailing, spacing: 4) {
                        if let weather = weatherDescription {
                            Text(weather)
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                        if let temp = temperature {
                            Text("\(Int(temp))°")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding(DreamSpacing.md)
        }
    }
}
