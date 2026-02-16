import SwiftUI

struct DreamWorldMapView: View {
    let dreams: [Dream]

    @State private var simulation = WorldGraphSimulation()
    @State private var selectedNode: WorldNode?

    private var worldCount: Int {
        Set(dreams.compactMap { $0.worldName }.filter { !$0.isEmpty }).count
    }

    var body: some View {
        if worldCount < 2 {
            ChroniclesEmptyStateView(
                icon: "map",
                title: "梦境世界尚在萌芽",
                subtitle: "再记录几个梦境，让世界之间的联系浮现"
            )
        } else {
            ZStack {
                GeometryReader { geo in
                    Canvas { context, size in
                        let offsetX = (size.width - 320) / 2
                        let offsetY = (size.height - 320) / 2

                        // Draw edges
                        for edge in simulation.edges {
                            guard let fromNode = simulation.nodes.first(where: { $0.id == edge.from }),
                                  let toNode = simulation.nodes.first(where: { $0.id == edge.to }) else { continue }

                            let from = CGPoint(x: fromNode.position.x + offsetX, y: fromNode.position.y + offsetY)
                            let to = CGPoint(x: toNode.position.x + offsetX, y: toNode.position.y + offsetY)

                            let midX = (from.x + to.x) / 2
                            let midY = (from.y + to.y) / 2 - 20

                            var path = Path()
                            path.move(to: from)
                            path.addQuadCurve(to: to, control: CGPoint(x: midX, y: midY))

                            context.stroke(path,
                                          with: .color(Color.auroraLavender.opacity(0.3)),
                                          style: StrokeStyle(lineWidth: 1 + edge.weight, lineCap: .round))
                        }

                        // Draw nodes
                        for node in simulation.nodes {
                            let pos = CGPoint(x: node.position.x + offsetX, y: node.position.y + offsetY)
                            let nodeSize = CGFloat(16 + node.dreamCount * 8)

                            // Glow
                            let glowRect = CGRect(x: pos.x - nodeSize, y: pos.y - nodeSize,
                                                  width: nodeSize * 2, height: nodeSize * 2)
                            context.fill(Circle().path(in: glowRect),
                                        with: .color(node.dominantEmotion.primaryColor.opacity(0.15)))

                            // Node circle
                            let nodeRect = CGRect(x: pos.x - nodeSize / 2, y: pos.y - nodeSize / 2,
                                                  width: nodeSize, height: nodeSize)
                            context.fill(Circle().path(in: nodeRect),
                                        with: .color(node.dominantEmotion.primaryColor.opacity(0.8)))

                            // Label
                            let label = Text(node.id)
                                .font(.system(size: 10, weight: .medium, design: .serif))
                                .foregroundColor(Color.deepBlueGray)
                            context.draw(label, at: CGPoint(x: pos.x, y: pos.y + nodeSize / 2 + 12))
                        }
                    }
                    .onTapGesture { location in
                        let offsetX = (geo.size.width - 320) / 2
                        let offsetY = (geo.size.height - 320) / 2

                        for node in simulation.nodes {
                            let pos = CGPoint(x: node.position.x + offsetX, y: node.position.y + offsetY)
                            let dist = sqrt(pow(location.x - pos.x, 2) + pow(location.y - pos.y, 2))
                            if dist < CGFloat(16 + node.dreamCount * 8) {
                                selectedNode = node
                                return
                            }
                        }
                        selectedNode = nil
                    }
                }

                if let node = selectedNode {
                    VStack {
                        Spacer()
                        WorldNodePopover(node: node, dreams: dreams) {
                            selectedNode = nil
                        }
                        .padding(.horizontal, DreamSpacing.md)
                        .padding(.bottom, DreamSpacing.lg)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.35), value: selectedNode?.id)
                }
            }
            .onAppear {
                simulation.buildGraph(from: dreams)
                simulation.startSimulation()
            }
            .onDisappear {
                simulation.stopSimulation()
            }
        }
    }
}

private struct WorldNodePopover: View {
    let node: WorldNode
    let dreams: [Dream]
    let onDismiss: () -> Void

    private var worldDreams: [Dream] {
        dreams.filter { $0.worldName == node.id }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DreamSpacing.sm) {
            HStack {
                Circle()
                    .fill(node.dominantEmotion.primaryColor)
                    .frame(width: 10, height: 10)
                Text(node.id)
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(Color.deepBlueGray)
                Spacer()
                Button { onDismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.mistyBlue)
                }
            }

            Text("\(worldDreams.count) 个梦境")
                .font(.system(size: 12))
                .foregroundStyle(Color.mistyBlue)

            if !node.symbols.isEmpty {
                HStack(spacing: 4) {
                    ForEach(Array(node.symbols).prefix(5), id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.deepBlueGray)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.ivoryGray))
                    }
                }
            }
        }
        .padding(DreamSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.pearlWhite)
                .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
        )
    }
}
