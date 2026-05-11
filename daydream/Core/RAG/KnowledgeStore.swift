import Foundation

struct KnowledgeDocument: Codable, Identifiable, Hashable {
    enum Source: String, Codable {
        case dreamMemory
        case tarotRule
    }

    let id: String
    let source: Source
    let title: String
    let content: String
    let metadata: [String: String]
    let vector: [Double]
    let updatedAt: Date
}

struct RetrievalResult: Identifiable, Hashable {
    let document: KnowledgeDocument
    let score: Double

    var id: String { document.id }
}

struct HashedEmbeddingProvider {
    let dimension: Int = 192

    func embed(_ text: String) -> [Double] {
        let tokens = tokenize(text)
        guard !tokens.isEmpty else { return Array(repeating: 0, count: dimension) }

        var vector = Array(repeating: 0.0, count: dimension)
        for token in tokens {
            let hash = stableHash(for: token)
            let index = Int(hash % UInt64(dimension))
            let sign = (hash & 1) == 0 ? 1.0 : -1.0
            let weight = 1.0 + min(Double(token.count), 6.0) * 0.12
            vector[index] += sign * weight
        }

        let norm = sqrt(vector.reduce(0) { $0 + ($1 * $1) })
        guard norm > 0 else { return vector }
        return vector.map { $0 / norm }
    }

    private func tokenize(_ text: String) -> [String] {
        let normalized = text
            .lowercased()
            .replacingOccurrences(of: "\n", with: " ")

        var tokens: [String] = []
        var latinBuffer = ""
        let characters = Array(normalized)

        for index in characters.indices {
            let char = characters[index]

            if char.isASCII && (char.isLetter || char.isNumber) {
                latinBuffer.append(char)
            } else {
                if !latinBuffer.isEmpty {
                    tokens.append(latinBuffer)
                    latinBuffer = ""
                }

                if !char.isWhitespace, !char.isPunctuation {
                    let single = String(char)
                    tokens.append(single)

                    if index < characters.count - 1 {
                        let next = characters[index + 1]
                        if !next.isWhitespace, !next.isPunctuation {
                            tokens.append(single + String(next))
                        }
                    }
                }
            }
        }

        if !latinBuffer.isEmpty {
            tokens.append(latinBuffer)
        }

        return tokens
    }

    private func stableHash(for token: String) -> UInt64 {
        token.unicodeScalars.reduce(1469598103934665603) { partial, scalar in
            (partial ^ UInt64(scalar.value)) &* 1099511628211
        }
    }
}

actor LocalVectorStore {
    static let shared = LocalVectorStore()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func replaceDocuments(_ documents: [KnowledgeDocument], for source: KnowledgeDocument.Source) async {
        do {
            let url = try fileURL(for: source)
            let data = try encoder.encode(documents)
            try ensureDirectoryExists(for: url)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Vector store replace failed for \(source.rawValue): \(error)")
        }
    }

    func loadDocuments(for source: KnowledgeDocument.Source) async -> [KnowledgeDocument] {
        do {
            let url = try fileURL(for: source)
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
            let data = try Data(contentsOf: url)
            return try decoder.decode([KnowledgeDocument].self, from: data)
        } catch {
            print("Vector store load failed for \(source.rawValue): \(error)")
            return []
        }
    }

    func search(query: String, in source: KnowledgeDocument.Source, topK: Int = 4) async -> [RetrievalResult] {
        let queryVector = HashedEmbeddingProvider().embed(query)
        let documents = await loadDocuments(for: source)

        return documents
            .map { document in
                RetrievalResult(document: document, score: cosineSimilarity(lhs: queryVector, rhs: document.vector))
            }
            .filter { $0.score > 0.02 }
            .sorted { $0.score > $1.score }
            .prefix(topK)
            .map { $0 }
    }

    private func cosineSimilarity(lhs: [Double], rhs: [Double]) -> Double {
        guard lhs.count == rhs.count, !lhs.isEmpty else { return 0 }
        return zip(lhs, rhs).reduce(0) { $0 + ($1.0 * $1.1) }
    }

    private func fileURL(for source: KnowledgeDocument.Source) throws -> URL {
        let baseURL: URL
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.xiaotian.daydream") {
            baseURL = appGroupURL
        } else {
            baseURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        }

        return baseURL
            .appendingPathComponent("RAG", isDirectory: true)
            .appendingPathComponent("\(source.rawValue).json")
    }

    private func ensureDirectoryExists(for fileURL: URL) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}

actor DreamMemoryIndexer {
    static let shared = DreamMemoryIndexer()

    func syncDreams(_ dreams: [Dream]) async {
        let documents = dreams.map(makeDocument(for:))
        await LocalVectorStore.shared.replaceDocuments(documents, for: .dreamMemory)
    }

    func search(query: String, dreams: [Dream], topK: Int = 4) async -> [RetrievalResult] {
        await syncDreams(dreams)
        return await LocalVectorStore.shared.search(query: query, in: .dreamMemory, topK: topK)
    }

    private func makeDocument(for dream: Dream) -> KnowledgeDocument {
        let content = [
            dream.transcript,
            dream.poem,
            dream.symbols.joined(separator: " "),
            dream.worldName ?? "",
            dream.reflectionQuestion ?? "",
            dream.locationName ?? "",
            dream.weatherDescription ?? "",
            dream.diary ?? "",
            dream.emotion.displayName
        ]
        .filter { !$0.isEmpty }
        .joined(separator: "\n")

        return KnowledgeDocument(
            id: dream.id.uuidString,
            source: .dreamMemory,
            title: dream.worldName?.isEmpty == false ? dream.worldName! : dream.createdAt.formatted(date: .abbreviated, time: .omitted),
            content: content,
            metadata: [
                "dreamID": dream.id.uuidString,
                "emotion": dream.emotion.rawValue,
                "emotionName": dream.emotion.displayName,
                "createdAt": dream.createdAt.ISO8601Format(),
                "symbols": dream.symbols.joined(separator: "、")
            ],
            vector: HashedEmbeddingProvider().embed(content),
            updatedAt: Date()
        )
    }
}

actor TarotKnowledgeIndexer {
    static let shared = TarotKnowledgeIndexer()

    func ensureIndexed() async {
        let existing = await LocalVectorStore.shared.loadDocuments(for: .tarotRule)
        guard existing.isEmpty else { return }
        let documents = buildDocuments()
        await LocalVectorStore.shared.replaceDocuments(documents, for: .tarotRule)
    }

    func search(query: String, topK: Int = 4) async -> [RetrievalResult] {
        await ensureIndexed()
        return await LocalVectorStore.shared.search(query: query, in: .tarotRule, topK: topK)
    }

    private func buildDocuments() -> [KnowledgeDocument] {
        let cardDocuments = TarotService.allCards.map { card in
            let content = """
            牌名：\(card.nameChinese) \(card.name)
            牌组：\(card.suit)
            正位：\(card.meaning)
            逆位：\(card.reversedMeaning)
            关键词：\(card.keywords.joined(separator: "、"))
            """

            return KnowledgeDocument(
                id: "tarot-card-\(card.name)",
                source: .tarotRule,
                title: card.nameChinese,
                content: content,
                metadata: [
                    "type": "card",
                    "name": card.name,
                    "nameChinese": card.nameChinese,
                    "suit": card.suit
                ],
                vector: HashedEmbeddingProvider().embed(content),
                updatedAt: Date()
            )
        }

        let spreadDocuments = TarotService.SpreadType.allCases.map { spread in
            let positions = spread.positions.joined(separator: "、")
            let content = "牌阵：\(spread.rawValue)\n位置含义：\(positions)\n适合用于结构化阅读与阶段判断。"

            return KnowledgeDocument(
                id: "tarot-spread-\(spread.rawValue)",
                source: .tarotRule,
                title: spread.rawValue,
                content: content,
                metadata: [
                    "type": "spread",
                    "name": spread.rawValue
                ],
                vector: HashedEmbeddingProvider().embed(content),
                updatedAt: Date()
            )
        }

        return cardDocuments + spreadDocuments
    }
}
