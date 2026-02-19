import Foundation

struct LocalAssistantEngineClient {
    let baseURL: URL

    func generate(prompt: String, provider: String, model: String) async throws -> String {
        struct Req: Codable { let prompt: String; let max_tokens: Int; let temperature: Double; let provider: String; let model: String }
        struct Res: Codable { let text: String }
        let req = Req(prompt: prompt, max_tokens: 256, temperature: 0.7, provider: provider, model: model)
        let res: Res = try await post(path: "/generate", body: req)
        return res.text
    }

    func chat(prompt: String, provider: String, model: String) async throws -> String {
        struct Req: Codable { let prompt: String; let max_tokens: Int; let temperature: Double; let provider: String; let model: String }
        struct Res: Codable { let answer: String?; let type: String; let tool: String?; let error: String? }

        let req = Req(prompt: prompt, max_tokens: 256, temperature: 0.2, provider: provider, model: model)
        let res: Res = try await post(path: "/chat", body: req)
        if let answer = res.answer { return answer }
        if res.type == "tool_error" {
            return "Tool error: \(res.tool ?? "") \(res.error ?? "")"
        }
        return "(no answer)"
    }

    func summarize(text: String, provider: String, model: String) async throws -> String {
        struct Req: Codable { let text: String; let style: String; let provider: String; let model: String }
        struct Res: Codable { let summary: String }
        let req = Req(text: text, style: "bullets", provider: provider, model: model)
        let res: Res = try await post(path: "/summarize", body: req)
        return res.summary
    }

    func emojiRewrite(text: String, provider: String, model: String) async throws -> String {
        struct Req: Codable { let text: String; let provider: String; let model: String }
        struct Res: Codable { let rewritten: String }
        let req = Req(text: text, provider: provider, model: model)
        let res: Res = try await post(path: "/emoji-rewrite", body: req)
        return res.rewritten
    }

    private func post<T: Codable, R: Codable>(path: String, body: T) async throws -> R {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "JarvisEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Bad response"])
        }
        return try JSONDecoder().decode(R.self, from: data)
    }
}
