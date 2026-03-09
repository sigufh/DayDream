import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var preferences = UserPreferences.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(ArtStyle.allCases) { style in
                        Button {
                            preferences.artStyle = style
                        } label: {
                            HStack(spacing: DreamSpacing.md) {
                                Image(systemName: style.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(
                                        preferences.artStyle == style
                                            ? Color.auroraLavender
                                            : Color.mistyBlue
                                    )
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(style.displayName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color.deepBlueGray)

                                    Text(style.description)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.mistyBlue)
                                        .lineLimit(2)
                                }

                                Spacer()

                                if preferences.artStyle == style {
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
                    Text("选择你喜欢的艺术风格，AI将以此风格生成梦境画面")
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
