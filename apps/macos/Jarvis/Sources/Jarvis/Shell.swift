import Foundation

enum Shell {
    static func which(_ cmd: String) -> String? {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        p.arguments = [cmd]
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = Pipe()
        do {
            try p.run()
            p.waitUntilExit()
        } catch {
            return nil
        }
        guard p.terminationStatus == 0 else { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func ollamaListModels() -> [String] {
        let out = run(["ollama", "list"]) ?? ""
        // Format:
        // NAME            ID              SIZE    MODIFIED
        // llama3.1:8b     ...
        let lines = out.split(separator: "\n").map(String.init)
        guard lines.count > 1 else { return [] }
        return lines.dropFirst().compactMap { line in
            let parts = line.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
            return parts.first
        }
    }

    static func run(_ args: [String]) -> String? {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        p.arguments = args
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = pipe
        do {
            try p.run()
            p.waitUntilExit()
        } catch {
            return nil
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }

    static func runStreaming(_ args: [String], onChunk: @escaping @Sendable (String) -> Void) async throws -> Int32 {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        p.arguments = args

        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = pipe

        try p.run()

        for try await data in pipe.fileHandleForReading.bytes {
            if let s = String(data: Data([data]), encoding: .utf8) {
                onChunk(s)
            }
        }

        p.waitUntilExit()
        return p.terminationStatus
    }
}
