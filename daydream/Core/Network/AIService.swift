import SwiftUI

@Observable
final class AIService {
    var isGenerating = false

    struct DreamContent {
        let imageData: Data?
        let poem: String
        let reflectionQuestion: String
        let worldName: String
        let symbols: [String]
    }

    func generateDreamContent(
        transcript: String,
        emotion: DreamEmotion,
        weather: String?,
        location: String?
    ) async -> DreamContent {
        isGenerating = true
        defer { isGenerating = false }

        // Simulate AI generation delay
        try? await Task.sleep(for: .seconds(Double.random(in: 2.5...4.0)))

        let poems: [DreamEmotion: [String]] = [
            .serenity: [
                "月光洒落在静谧的湖面\n涟漪轻抚着沉睡的星辰\n风带来远方的低语\n梦境在此刻凝固成画",
                "云朵编织的摇篮里\n时间放慢了脚步\n我听见花开的声音\n在这片宁静中绽放"
            ],
            .melancholy: [
                "雨落在记忆的窗台\n模糊了那年的轮廓\n我在梦中寻找\n一个再也回不去的拥抱",
                "旧照片泛黄的边角\n藏着说不出的思念\n月光下的影子\n拉长了离别的距离"
            ],
            .anxiety: [
                "时钟的指针追逐着我\n走廊没有尽头\n门在身后关闭\n而钥匙藏在梦的缝隙里",
                "风暴中的纸飞机\n颤抖着寻找方向\n雷声是心跳的回响\n在混沌中等待黎明"
            ],
            .hope: [
                "破晓时分的第一缕光\n穿透了漫长的黑夜\n种子在冻土下苏醒\n春天正从远方走来",
                "星河的尽头有一扇门\n钥匙就在手心发光\n每一步都在靠近\n那个期待已久的明天"
            ],
            .whimsy: [
                "鲸鱼在云端游泳\n月亮是它的玩伴\n我骑着纸鹤飞过彩虹\n降落在糖果做的岛屿",
                "时钟倒着走\n猫咪会说话\n花朵在歌唱\n这是属于我的奇妙世界"
            ]
        ]

        let questions: [String] = [
            "在这个梦中，什么让你感到最安心？",
            "如果可以回到梦里，你最想改变什么？",
            "梦中的那个人，是否代表了你内心的某个声音？",
            "这个梦想告诉你什么关于此刻生活的信息？",
            "梦境中的颜色让你联想到了什么？"
        ]

        let worlds = ["浮光之境", "星河彼岸", "云上花园", "月影深处", "梦的尽头"]
        let symbolSets = [
            ["月亮", "水", "光"],
            ["飞翔", "门", "钥匙"],
            ["花", "雨", "镜子"],
            ["星辰", "路", "桥"],
            ["风", "树", "鸟"]
        ]

        let poem = poems[emotion]?.randomElement() ?? "梦的碎片在指间散落\n化作一缕微光"
        let question = questions.randomElement() ?? "这个梦想告诉你什么？"
        let world = worlds.randomElement() ?? "梦境"
        let symbols = symbolSets.randomElement() ?? ["梦"]

        // Generate a placeholder gradient image
        let imageData = generatePlaceholderImage(emotion: emotion)

        return DreamContent(
            imageData: imageData,
            poem: poem,
            reflectionQuestion: question,
            worldName: world,
            symbols: symbols
        )
    }

    private func generatePlaceholderImage(emotion: DreamEmotion) -> Data? {
        let size = CGSize(width: 400, height: 533)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let colors = emotion.gradient.map { UIColor($0) }
            let cgColors = colors.map { $0.cgColor }
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: cgColors as CFArray,
                locations: [0, 0.5, 1]
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
        return image.jpegData(compressionQuality: 0.8)
    }
}
