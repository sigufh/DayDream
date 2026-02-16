import SwiftUI

struct WordCloudView: View {
    let divinations: [Divination]
    let dreams: [Dream]

    @State private var layout = WordCloudLayout()

    var body: some View {
        Canvas { context, size in
            for item in layout.items {
                let text = Text(item.word)
                    .font(.system(size: item.fontSize, weight: .light, design: .serif))
                    .foregroundColor(item.color)
                context.draw(text, at: CGPoint(x: item.x + size.width / 2,
                                                y: item.y + size.height / 2))
            }
        }
        .frame(height: 200)
        .onAppear {
            layout.compute(divinations: divinations, dreams: dreams)
        }
    }
}

@Observable
final class WordCloudLayout {
    struct LayoutItem {
        let word: String
        let fontSize: CGFloat
        let color: Color
        var x: CGFloat
        var y: CGFloat
    }

    var items: [LayoutItem] = []

    private let emotionColors: [Color] = DreamEmotion.allCases.map { $0.primaryColor }

    func compute(divinations: [Divination], dreams: [Dream]) {
        var wordCounts: [String: Int] = [:]

        // Count leaf names from divinations
        for div in divinations {
            for leaf in div.leaves {
                wordCounts[leaf, default: 0] += 1
            }
        }

        // Count symbols from dreams
        for dream in dreams {
            for symbol in dream.symbols {
                wordCounts[symbol, default: 0] += 1
            }
        }

        guard !wordCounts.isEmpty else { return }

        let maxCount = CGFloat(wordCounts.values.max() ?? 1)
        let sorted = wordCounts.sorted { $0.value > $1.value }

        var placed: [LayoutItem] = []

        for (index, entry) in sorted.enumerated() {
            let fraction = CGFloat(entry.value) / maxCount
            let fontSize = 12 + fraction * 20
            let color = emotionColors[index % emotionColors.count]

            // Spiral placement
            let position = spiralPlace(index: index, existing: placed, fontSize: fontSize)

            placed.append(LayoutItem(
                word: entry.key,
                fontSize: fontSize,
                color: color.opacity(0.6 + fraction * 0.4),
                x: position.x,
                y: position.y
            ))
        }

        items = placed
    }

    private func spiralPlace(index: Int, existing: [LayoutItem], fontSize: CGFloat) -> CGPoint {
        let angleStep: CGFloat = 0.5
        let radiusStep: CGFloat = 3

        for step in 0..<200 {
            let angle = CGFloat(step) * angleStep
            let radius = CGFloat(step) * radiusStep
            let x = cos(angle) * radius
            let y = sin(angle) * radius

            let width = fontSize * CGFloat(2)
            let height = fontSize * 1.3
            let rect = CGRect(x: x - width / 2, y: y - height / 2, width: width, height: height)

            var overlaps = false
            for item in existing {
                let itemWidth = item.fontSize * 2
                let itemHeight = item.fontSize * 1.3
                let itemRect = CGRect(x: item.x - itemWidth / 2, y: item.y - itemHeight / 2,
                                      width: itemWidth, height: itemHeight)
                if rect.intersects(itemRect) {
                    overlaps = true
                    break
                }
            }

            if !overlaps {
                return CGPoint(x: x, y: y)
            }
        }

        return CGPoint(x: CGFloat.random(in: -60...60), y: CGFloat.random(in: -60...60))
    }
}
