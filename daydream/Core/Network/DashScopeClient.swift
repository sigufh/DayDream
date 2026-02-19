import Foundation

actor DashScopeClient {
    private let session: URLSession
    private let apiKey: String

    private let chatURL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions"
    private let imageGenURL = "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation"

    init(apiKey: String = APIConfig.dashScopeAPIKey) {
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }

    // MARK: - Chat Completion (Qwen)

    func chat(system: String, userMessage: String, maxTokens: Int = 2048) async throws -> String {
        guard !apiKey.isEmpty else { throw APIError.missingAPIKey }
        guard let url = URL(string: chatURL) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "qwen-flash",
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": userMessage]
            ],
            "max_tokens": maxTokens,
            "temperature": 0.8
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let messageObj = first["message"] as? [String: Any],
              let content = messageObj["content"] as? String else {
            throw APIError.decodingError("Failed to parse chat response")
        }

        return content
    }

    // MARK: - Image Generation (Wan 2.6, Synchronous)

    func generateImage(prompt: String, negativePrompt: String = "text, watermark, blurry, low quality", size: String = "768*1024") async throws -> Data {
        guard !apiKey.isEmpty else { throw APIError.missingAPIKey }
        guard let url = URL(string: imageGenURL) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "wan2.6-t2i",
            "input": [
                "messages": [
                    [
                        "role": "user",
                        "content": [
                            ["text": prompt]
                        ]
                    ]
                ]
            ],
            "parameters": [
                "size": size,
                "n": 1,
                "watermark": false,
                "prompt_extend": true,
                "negative_prompt": negativePrompt
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // Synchronous call — server blocks until image is ready
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        let json = try JSONSerialization.jsonObject(with: data)
        print("[ImageGen] Response: \(json)")

        guard let dict = json as? [String: Any],
              let output = dict["output"] as? [String: Any] else {
            let raw = String(data: data, encoding: .utf8) ?? "nil"
            throw APIError.decodingError("Failed to parse image generation response: \(raw.prefix(500))")
        }

        return try await extractImageData(from: output)
    }

    // MARK: - Image Extraction

    private func extractImageData(from output: [String: Any]) async throws -> Data {
        // Try output.results[].url
        if let results = output["results"] as? [[String: Any]],
           let firstResult = results.first,
           let imageURLString = firstResult["url"] as? String,
           let imageURL = URL(string: imageURLString) {
            return try await downloadImage(from: imageURL)
        }
        // Try output.results[].b64_image
        if let results = output["results"] as? [[String: Any]],
           let firstResult = results.first,
           let b64 = firstResult["b64_image"] as? String,
           let imageData = Data(base64Encoded: b64) {
            return imageData
        }
        // Try output.choices[].message.content[].image (multimodal sync format)
        if let choices = output["choices"] as? [[String: Any]],
           let first = choices.first,
           let message = first["message"] as? [String: Any],
           let content = message["content"] as? [[String: Any]] {
            for item in content {
                if let urlString = item["image"] as? String,
                   let url = URL(string: urlString) {
                    return try await downloadImage(from: url)
                }
            }
        }
        // Try output.result_url
        if let resultURL = output["result_url"] as? String,
           let imageURL = URL(string: resultURL) {
            return try await downloadImage(from: imageURL)
        }

        let desc = String(describing: output)
        print("[ImageGen] Unexpected output format: \(desc)")
        throw APIError.decodingError("No image found in response. Output: \(desc.prefix(500))")
    }

    private func downloadImage(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        return data
    }
}
