import SwiftUI

enum ImageModel: String, CaseIterable, Identifiable {
    case wanx = "wanx-v1"
    case flux = "flux-schnell"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wanx: return "万相"
        case .flux: return "通义千问图像"
        }
    }

    var description: String {
        switch self {
        case .wanx: return "通义万相，快速生成，适合大多数场景"
        case .flux: return "Qwen-Image-2.0，高质量图像生成"
        }
    }

    var icon: String {
        switch self {
        case .wanx: return "sparkles"
        case .flux: return "star.fill"
        }
    }

    var modelName: String {
        switch self {
        case .wanx: return "wanx-v1"
        case .flux: return "flux-schnell"
        }
    }
}

@Observable
final class UserPreferences {
    static let shared = UserPreferences()

    var selectedSkillID: String {
        didSet {
            UserDefaults.standard.set(selectedSkillID, forKey: "selectedSkillID")
        }
    }

    var artStyle: ArtStyle {
        get { currentSkill.legacyArtStyle }
        set {
            selectedSkillID = SkillRegistry.styleSkill(for: newValue).id
            UserDefaults.standard.set(newValue.rawValue, forKey: "artStyle")
        }
    }

    var imageModel: ImageModel {
        didSet {
            UserDefaults.standard.set(imageModel.rawValue, forKey: "imageModel")
        }
    }

    var currentSkill: StyleSkillProfile {
        SkillRegistry.styleSkill(for: selectedSkillID)
    }

    private init() {
        if let savedSkillID = UserDefaults.standard.string(forKey: "selectedSkillID") {
            self.selectedSkillID = SkillRegistry.styleSkill(for: savedSkillID).id
        } else if let savedStyle = UserDefaults.standard.string(forKey: "artStyle"),
                  let style = ArtStyle(rawValue: savedStyle) {
            self.selectedSkillID = SkillRegistry.styleSkill(for: style).id
        } else {
            self.selectedSkillID = SkillRegistry.builtInSkills[0].id
        }

        if let saved = UserDefaults.standard.string(forKey: "imageModel"),
           let model = ImageModel(rawValue: saved) {
            self.imageModel = model
        } else {
            self.imageModel = .wanx // Default
        }
    }
}
