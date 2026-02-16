import Foundation
import SwiftData

@Model
final class Divination {
    var id: UUID
    var date: Date
    var leaves: [String]
    var interpretation: String
    var relatedDreamID: UUID?

    init(
        leaves: [String] = [],
        interpretation: String = "",
        relatedDreamID: UUID? = nil
    ) {
        self.id = UUID()
        self.date = Date()
        self.leaves = leaves
        self.interpretation = interpretation
        self.relatedDreamID = relatedDreamID
    }
}
