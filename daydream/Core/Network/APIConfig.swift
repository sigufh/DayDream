import Foundation

nonisolated enum APIError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL
    case httpError(statusCode: Int, message: String)
    case decodingError(String)
    case networkError(Error)
    case taskTimeout
    case taskFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is missing"
        case .invalidURL:
            return "Invalid URL"
        case .httpError(let code, let message):
            return "HTTP \(code): \(message)"
        case .decodingError(let detail):
            return "Decoding error: \(detail)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .taskTimeout:
            return "Task timed out"
        case .taskFailed(let message):
            return "Task failed: \(message)"
        }
    }
}

nonisolated enum APIConfig {
    static var dashScopeAPIKey: String {
        if let key = Bundle.main.infoDictionary?["DASHSCOPE_API_KEY"] as? String,
           !key.isEmpty,
           key != "sk-your-key-here" {
            return key
        }
        #if DEBUG
        print("⚠️ DashScope API key not configured. Using fallback mock data.")
        #endif
        return ""
    }

    static var hasValidAPIKey: Bool {
        !dashScopeAPIKey.isEmpty
    }
}
