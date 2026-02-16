import SwiftUI

struct EmotionSphereCanvas: View {
    let dreams: [Dream]

    @State private var rotation: Double = 0

    private var emotionDistribution: [(emotion: DreamEmotion, count: Int, fraction: CGFloat)] {
        let total = max(dreams.count, 1)
        var counts: [DreamEmotion: Int] = [:]
        for dream in dreams {
            counts[dream.emotion, default: 0] += 1
        }
        return DreamEmotion.allCases.compactMap { emotion in
            guard let count = counts[emotion], count > 0 else { return nil }
            return (emotion, count, CGFloat(count) / CGFloat(total))
        }.sorted { $0.count > $1.count }
    }

    private var dominantEmotion: DreamEmotion {
        emotionDistribution.first?.emotion ?? .serenity
    }

    var body: some View {
        VStack(spacing: DreamSpacing.md) {
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius: CGFloat = 110

                    // Blurred glow layer
                    let glowRect = CGRect(x: center.x - radius - 20, y: center.y - radius - 20,
                                          width: (radius + 20) * 2, height: (radius + 20) * 2)
                    context.fill(Ellipse().path(in: glowRect),
                                 with: .color(dominantEmotion.primaryColor.opacity(0.15)))

                    let time = timeline.date.timeIntervalSinceReferenceDate

                    // Draw brush-stroke arcs per emotion
                    var startAngle: Double = time * 0.1 // slow rotation
                    for item in emotionDistribution {
                        let sweepAngle = Double(item.fraction) * 2 * .pi
                        let strokeCount = max(Int(item.fraction * 25), 3)

                        for i in 0..<strokeCount {
                            let seed = Double(item.emotion.rawValue.hashValue &+ i)
                            let lineWidth = CGFloat(8 + abs(sin(seed * 1.3)) * 17)
                            let opacity = 0.3 + abs(sin(seed * 2.7)) * 0.5
                            let angleJitter = sin(seed * 3.1 + time * 0.5) * 0.08
                            let radiusJitter = CGFloat(sin(seed * 1.7) * 15)

                            let arcStart = Angle(radians: startAngle + Double(i) * sweepAngle / Double(strokeCount) + angleJitter)
                            let arcEnd = Angle(radians: startAngle + Double(i + 1) * sweepAngle / Double(strokeCount) + angleJitter)

                            var path = Path()
                            path.addArc(center: center, radius: radius + radiusJitter,
                                       startAngle: arcStart, endAngle: arcEnd, clockwise: false)

                            context.stroke(path,
                                          with: .color(item.emotion.primaryColor.opacity(opacity)),
                                          style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        }
                        startAngle += sweepAngle
                    }

                    // Center overlay: count + emotion name
                    let countText = Text("\(dreams.count)")
                        .font(.system(size: 36, weight: .light, design: .serif))
                        .foregroundColor(Color.deepBlueGray)
                    context.draw(countText, at: CGPoint(x: center.x, y: center.y - 10))

                    let emotionText = Text(dominantEmotion.displayName)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.mistyBlue)
                    context.draw(emotionText, at: CGPoint(x: center.x, y: center.y + 20))
                }
            }
            .frame(width: 260, height: 260)
        }
    }
}
