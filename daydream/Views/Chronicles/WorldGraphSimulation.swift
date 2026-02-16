import SwiftUI

struct WorldNode: Identifiable {
    let id: String // worldName
    var position: CGPoint
    var velocity: CGPoint = .zero
    var dreamCount: Int
    var dominantEmotion: DreamEmotion
    var symbols: Set<String>
}

struct WorldEdge: Identifiable {
    var id: String { "\(from)-\(to)" }
    let from: String
    let to: String
    let sharedSymbols: Set<String>
    var weight: CGFloat { CGFloat(sharedSymbols.count) }
}

@Observable
final class WorldGraphSimulation {
    var nodes: [WorldNode] = []
    var edges: [WorldEdge] = []
    private var timer: Timer?
    private var frameCount = 0

    func buildGraph(from dreams: [Dream]) {
        var worldMap: [String: (count: Int, emotions: [DreamEmotion], symbols: Set<String>)] = [:]

        for dream in dreams {
            guard let name = dream.worldName, !name.isEmpty else { continue }
            var entry = worldMap[name] ?? (count: 0, emotions: [], symbols: [])
            entry.count += 1
            entry.emotions.append(dream.emotion)
            for symbol in dream.symbols {
                entry.symbols.insert(symbol)
            }
            worldMap[name] = entry
        }

        // Create nodes with random initial positions
        let center = CGPoint(x: 160, y: 160)
        nodes = worldMap.map { name, data in
            let angle = Double.random(in: 0...(2 * .pi))
            let dist = CGFloat.random(in: 30...120)
            let pos = CGPoint(x: center.x + cos(angle) * dist, y: center.y + sin(angle) * dist)

            // Determine dominant emotion
            var emotionCounts: [DreamEmotion: Int] = [:]
            for e in data.emotions { emotionCounts[e, default: 0] += 1 }
            let dominant = emotionCounts.max(by: { $0.value < $1.value })?.key ?? .serenity

            return WorldNode(id: name, position: pos, dreamCount: data.count,
                           dominantEmotion: dominant, symbols: data.symbols)
        }

        // Create edges from shared symbols
        edges = []
        for i in nodes.indices {
            for j in (i + 1)..<nodes.count {
                let shared = nodes[i].symbols.intersection(nodes[j].symbols)
                if !shared.isEmpty {
                    edges.append(WorldEdge(from: nodes[i].id, to: nodes[j].id, sharedSymbols: shared))
                }
            }
        }
    }

    func startSimulation() {
        frameCount = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.step()
            self.frameCount += 1
            // Slow down after 2 seconds (120 frames)
            if self.frameCount > 120 {
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 10, repeats: true) { [weak self] _ in
                    self?.step()
                }
            }
        }
    }

    func stopSimulation() {
        timer?.invalidate()
        timer = nil
    }

    private func step() {
        guard nodes.count > 1 else { return }

        let center = CGPoint(x: 160, y: 160)
        let friction: CGFloat = 0.85

        for i in nodes.indices {
            var force = CGPoint.zero

            // Repulsion from other nodes (Coulomb)
            for j in nodes.indices where i != j {
                let dx = nodes[i].position.x - nodes[j].position.x
                let dy = nodes[i].position.y - nodes[j].position.y
                let dist = max(sqrt(dx * dx + dy * dy), 1)
                let repulsion: CGFloat = 3000 / (dist * dist)
                force.x += (dx / dist) * repulsion
                force.y += (dy / dist) * repulsion
            }

            // Spring attraction along edges
            for edge in edges {
                let otherID: String?
                if edge.from == nodes[i].id { otherID = edge.to }
                else if edge.to == nodes[i].id { otherID = edge.from }
                else { otherID = nil }

                if let otherID, let j = nodes.firstIndex(where: { $0.id == otherID }) {
                    let dx = nodes[j].position.x - nodes[i].position.x
                    let dy = nodes[j].position.y - nodes[i].position.y
                    let dist = sqrt(dx * dx + dy * dy)
                    let springK: CGFloat = 0.02 * edge.weight
                    let targetDist: CGFloat = 80
                    let displacement = dist - targetDist
                    force.x += (dx / max(dist, 1)) * displacement * springK
                    force.y += (dy / max(dist, 1)) * displacement * springK
                }
            }

            // Centering force
            force.x += (center.x - nodes[i].position.x) * 0.005
            force.y += (center.y - nodes[i].position.y) * 0.005

            // Apply force
            nodes[i].velocity.x = (nodes[i].velocity.x + force.x) * friction
            nodes[i].velocity.y = (nodes[i].velocity.y + force.y) * friction
            nodes[i].position.x += nodes[i].velocity.x
            nodes[i].position.y += nodes[i].velocity.y
        }
    }
}
