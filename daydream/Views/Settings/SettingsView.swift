import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var preferences = UserPreferences.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(SkillRegistry.builtInSkills, id: \.id) { skill in
                        Button {
                            preferences.selectedSkillID = skill.id
                        } label: {
                            HStack(spacing: DreamSpacing.md) {
                                Image(systemName: skill.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(
                                        preferences.currentSkill.id == skill.id
                                            ? Color.auroraLavender
                                            : Color.mistyBlue
                                    )
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(skill.definition.displayName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color.deepBlueGray)

                                    Text(skill.definition.description)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.mistyBlue)
                                        .lineLimit(2)
                                }

                                Spacer()

                                if preferences.currentSkill.id == skill.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.auroraLavender)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("艺术风格")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.deepBlueGray)
                } footer: {
                    Text("选择你喜欢的艺术风格，应用会把它作为内部 skill，统一影响梦境画面、诗歌与代理解读语气")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mistyBlue)
                }

                Section {
                    ForEach(ImageModel.allCases) { model in
                        Button {
                            preferences.imageModel = model
                        } label: {
                            HStack(spacing: DreamSpacing.md) {
                                Image(systemName: model.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(
                                        preferences.imageModel == model
                                            ? Color.auroraLavender
                                            : Color.mistyBlue
                                    )
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(model.displayName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color.deepBlueGray)

                                    Text(model.description)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.mistyBlue)
                                        .lineLimit(2)
                                }

                                Spacer()

                                if preferences.imageModel == model {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.auroraLavender)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("图片生成模型")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.deepBlueGray)
                } footer: {
                    Text("通义千问图像质量更高，万相速度快适合快速预览")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mistyBlue)
                }

                Section {
                    HStack {
                        Text("版本")
                            .foregroundStyle(Color.deepBlueGray)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(Color.mistyBlue)
                    }
                } header: {
                    Text("关于")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.deepBlueGray)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.pearlWhite)
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("完成")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.auroraLavender)
                    }
                }
            }
        }
    }
}
