import SwiftUI

struct DreamCardFront: View {
    let dream: Dream

    var body: some View {
        PolaroidCardView(
            imageData: dream.imageData,
            poem: dream.poem,
            emotion: dream.emotion,
            date: dream.createdAt,
            weather: dream.weatherDescription,
            showDate: true,
            showWeather: dream.weatherDescription != nil
        )
    }
}
