import Foundation

actor QwenImageClient {
    private let session: URLSession
    private let apiKey: String

    private let imageGenURL = "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation"

    init(apiKey: String = APIConfig.dashScopeAPIKey) {
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }

    func generateImage(prompt: String, negativePrompt: String = "text, watermark, blurry, low quality", size: String = "768*1024") async throws -> Data {
        guard !apiKey.isEmpty else { throw APIError.missingAPIKey }
        guard let url = URL(string: imageGenURL) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "qwen-image-2.0",
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
                "negative_prompt": negativePrompt
            ]
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

        let json = try JSONSerialization.jsonObject(with: data)
        print("[QwenImage] Response: \(json)")

        guard let dict = json as? [String: Any],
              let output = dict["output"] as? [String: Any],
              let choices = output["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? [[String: Any]],
              let imageContent = content.first,
              let imageURLString = imageContent["image"] as? String,
              let imageURL = URL(string: imageURLString) else {
            throw APIError.decodingError("Failed to parse qwen-image response")
        }

        let (imageData, _) = try await session.data(from: imageURL)
        return imageData
    }
}

