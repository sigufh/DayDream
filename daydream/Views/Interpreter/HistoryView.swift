import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Divination.date, order: .reverse) private var allDivinations: [Divination]
    @Query(sort: \Dream.createdAt, order: .reverse) private var allDreams: [Dream]

    @State private var searchText = ""
    @State private var selectedEmotion: DreamEmotion? = nil
    @State private var showFavoritesOnly = false
    @State private var selectedType: RecordType? = nil

    enum RecordType: String, CaseIterable {
        case divination = "问签"
        case dream = "梦境"
    }

    var filteredDivinations: [Divination] {
        guard selectedType == nil || selectedType == .divination else { return [] }

        var result = allDivinations

        if !searchText.isEmpty {
            result = result.filter { divination in
                divination.interpretation.localizedCaseInsensitiveContains(searchText) ||
                (divination.hexagramName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return result
    }

    var filteredDreams: [Dream] {
        guard selectedType == nil || selectedType == .dream else { return [] }

        var result = allDreams

        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        if let emotion = selectedEmotion {
            result = result.filter { $0.emotion == emotion }
        }

        if !searchText.isEmpty {
            result = result.filter { dream in
                dream.transcript.localizedCaseInsensitiveContains(searchText) ||
                dream.poem.localizedCaseInsensitiveContains(searchText) ||
                dream.symbols.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏（顶部固定）
            HStack(spacing: DreamSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))

                TextField("搜索记录...", text: $searchText)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, DreamSpacing.md)
            .padding(.vertical, DreamSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.1))
            )
            .padding(.horizontal, DreamSpacing.md)
            .padding(.top, DreamSpacing.sm)

            // 筛选器（顶部固定）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DreamSpacing.sm) {
                    // 类型筛选
                    RecordTypeChip(type: nil, label: "全部", isSelected: selectedType == nil) {
                        selectedType = nil
                    }

                    ForEach(RecordType.allCases, id: \.self) { type in
                        RecordTypeChip(type: type, label: type.rawValue, isSelected: selectedType == type) {
                            selectedType = selectedType == type ? nil : type
                        }
                    }

                    Divider()
                        .frame(height: 20)
                        .background(.white.opacity(0.2))

                    // 收藏筛选
                    FilterChipWhite(
                        icon: "heart.fill",
                        label: "收藏",
                        isSelected: showFavoritesOnly
                    ) {
                        showFavoritesOnly.toggle()
                    }

                    // 情绪筛选
                    ForEach(DreamEmotion.allCases) { emotion in
                        FilterChipWhite(
                            icon: nil,
                            label: emotion.displayName,
                            isSelected: selectedEmotion == emotion
                        ) {
                            if selectedEmotion == emotion {
                                selectedEmotion = nil
                            } else {
                                selectedEmotion = emotion
                            }
                        }
                    }
                }
                .padding(.horizontal, DreamSpacing.md)
            }
            .padding(.vertical, DreamSpacing.sm)

            // 内容列表
            ScrollView {
                VStack(spacing: DreamSpacing.xl) {
                    Spacer()
                        .frame(height: DreamSpacing.sm)

                    // 问签记录
                    if !filteredDivinations.isEmpty {
                        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                            Text("问签记录")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.horizontal, DreamSpacing.md)

                            DivinationHistoryList(divinations: filteredDivinations)
                                .padding(.horizontal, DreamSpacing.md)
                        }
                    }

                    // 梦境记录
                    if !filteredDreams.isEmpty {
                        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
                            Text("梦境记录")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.horizontal, DreamSpacing.md)

                            LazyVStack(spacing: DreamSpacing.sm) {
                                ForEach(filteredDreams) { dream in
                                    DreamHistoryRow(dream: dream)
                                }
                            }
                            .padding(.horizontal, DreamSpacing.md)
                        }
                    }

                    if filteredDivinations.isEmpty && filteredDreams.isEmpty {
                        if allDivinations.isEmpty && allDreams.isEmpty {
                            emptyState
                        } else {
                            EmptySearchResultViewWhite()
                        }
                    }

                    Spacer()
                        .frame(height: DreamSpacing.xl)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var emptyState: some View {
        VStack(spacing: DreamSpacing.lg) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(Color.auroraLavender.opacity(0.5))

            VStack(spacing: DreamSpacing.sm) {
                Text("暂无记录")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundStyle(.white)

                Text("记录你的梦境和占卜，开始探索内在世界")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, DreamSpacing.xl)
        .padding(.top, 100)
    }
}

// 记录类型筛选芯片
private struct RecordTypeChip: View {
    let type: HistoryView.RecordType?
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, DreamSpacing.md)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                )
        }
    }
}

// 白色主题筛选芯片
private struct FilterChipWhite: View {
    let icon: String?
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                }
                Text(label)
                    .font(.system(size: 12, weight: isSelected ? .medium : .regular))
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, DreamSpacing.md)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.auroraLavender.opacity(0.6) : Color.white.opacity(0.05))
            )
        }
    }
}

// 空搜索结果（白色主题）
private struct EmptySearchResultViewWhite: View {
    var body: some View {
        VStack(spacing: DreamSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.3))

            Text("没有找到匹配的记录")
                .font(.system(size: 16, weight: .light, design: .serif))
                .foregroundStyle(.white.opacity(0.8))

            Text("试试其他关键词或筛选条件")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.top, 100)
    }
}

private struct DreamHistoryRow: View {
    let dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
            HStack {
                Text(dream.createdAt.formatted(.dateTime.month().day().hour().minute()))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))

                Spacer()

                Text(dream.emotion.displayName)
                    .font(.system(size: 11))
                    .foregroundStyle(dream.emotion.primaryColor)
            }

            Text(dream.transcript)
                .font(.system(size: 13, weight: .light, design: .serif))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(2)
                .lineSpacing(4)

            if !dream.symbols.isEmpty {
                HStack(spacing: 6) {
                    ForEach(dream.symbols.prefix(5), id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.06))
        )
    }
}
