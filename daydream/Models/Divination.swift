import Foundation
import SwiftData

@Model
final class Divination {
    var id: UUID
    var date: Date
    var leaves: [String]  // 六爻类型："老阳", "少阴"... 或旧版叶子名称
    var hexagramName: String?  // 本卦卦名："乾", "坤"...（新版）
    var hexagramMeaning: String?  // 本卦卦义："天", "地"...（新版）
    var transformedHexagramName: String?  // 变卦卦名
    var transformedHexagramMeaning: String?  // 变卦卦义
    var movingYaoIndices: [Int]?  // 动爻位置：[0, 2, 5]（新版）
    var interpretation: String
    var relatedDreamID: UUID?

    init(
        leaves: [String] = [],
        hexagramName: String? = nil,
        hexagramMeaning: String? = nil,
        transformedHexagramName: String? = nil,
        transformedHexagramMeaning: String? = nil,
        movingYaoIndices: [Int]? = nil,
        interpretation: String = "",
        relatedDreamID: UUID? = nil
    ) {
        self.id = UUID()
        self.date = Date()
        self.leaves = leaves
        self.hexagramName = hexagramName
        self.hexagramMeaning = hexagramMeaning
        self.transformedHexagramName = transformedHexagramName
        self.transformedHexagramMeaning = transformedHexagramMeaning
        self.movingYaoIndices = movingYaoIndices
        self.interpretation = interpretation
        self.relatedDreamID = relatedDreamID
    }
}
