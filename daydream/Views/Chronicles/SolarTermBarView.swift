import SwiftUI

struct SolarTermBarView: View {
    @State private var expandedTermID: String?

    private let currentTerm = SolarTerm.currentTerm()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DreamSpacing.sm) {
                    ForEach(SolarTerm.allTerms) { term in
                        SolarTermPill(
                            term: term,
                            isCurrent: term.id == currentTerm.id,
                            isExpanded: expandedTermID == term.id
                        )
                        .id(term.id)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                expandedTermID = expandedTermID == term.id ? nil : term.id
                            }
                        }
                    }
                }
                .padding(.horizontal, DreamSpacing.md)
                .padding(.vertical, DreamSpacing.sm)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        proxy.scrollTo(currentTerm.id, anchor: .center)
                    }
                }
            }
        }
    }
}

private struct SolarTermPill: View {
    let term: SolarTerm
    let isCurrent: Bool
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: isExpanded ? DreamSpacing.xs : 0) {
            HStack(spacing: DreamSpacing.xs) {
                // Color gradient indicator
                Circle()
                    .fill(
                        LinearGradient(colors: term.colors,
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
                    .frame(width: 8, height: 8)

                Text(term.chineseName)
                    .font(.system(size: 12, weight: isCurrent ? .medium : .regular, design: .serif))
                    .foregroundStyle(isCurrent ? Color.deepBlueGray : Color.mistyBlue)

                Text(term.date)
                    .font(.system(size: 9))
                    .foregroundStyle(Color.mistyBlue.opacity(0.7))
            }

            if isExpanded {
                Text(term.poem)
                    .font(.system(size: 11, weight: .light, design: .serif))
                    .foregroundStyle(Color.deepBlueGray.opacity(0.8))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 140)

                HStack(spacing: 4) {
                    ForEach(term.colors.indices, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(term.colors[i])
                            .frame(width: 20, height: 6)
                    }
                }
            }
        }
        .padding(.horizontal, DreamSpacing.sm + 2)
        .padding(.vertical, DreamSpacing.xs + 2)
        .background(
            Capsule()
                .fill(isCurrent ? Color.auroraLavender.opacity(0.15) : Color.ivoryGray.opacity(0.6))
        )
        .overlay(
            Capsule()
                .stroke(isCurrent ? Color.auroraLavender.opacity(0.6) : Color.clear, lineWidth: 1)
        )
    }
}
