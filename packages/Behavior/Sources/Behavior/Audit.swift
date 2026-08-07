import Foundation

/// Append-only scrutiny record for gated actions.
public struct ConfirmReceipt: Sendable, Codable, Equatable, Identifiable {
    public var id: String
    public var at: Date
    public var mode: String
    public var outcome: String
    public var title: String
    public var risk: String
    public var steps: [String]
    public var userConfirmed: Bool
    public var detail: String?

    public init(
        id: String = UUID().uuidString,
        at: Date = Date(),
        mode: String,
        outcome: String,
        title: String,
        risk: String,
        steps: [String],
        userConfirmed: Bool,
        detail: String? = nil
    ) {
        self.id = id
        self.at = at
        self.mode = mode
        self.outcome = outcome
        self.title = title
        self.risk = risk
        self.steps = steps
        self.userConfirmed = userConfirmed
        self.detail = detail
    }
}

public enum AuditPaths: Sendable {
    /// `STEALTH_AUDIT_PATH` override, else Application Support `audit.jsonl`
    public static func defaultAuditURL() throws -> URL {
        if let override = ProcessInfo.processInfo.environment["STEALTH_AUDIT_PATH"], !override.isEmpty {
            let url = URL(fileURLWithPath: override)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            return url
        }
        let root = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = root.appendingPathComponent("StealthStartup", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("audit.jsonl", isDirectory: false)
    }
}

/// JSONL audit log. Never stores secret field values — titles/steps only.
public actor AuditLog {
    private let fileURL: URL?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL? = nil) {
        self.fileURL = fileURL
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func path() -> String? {
        fileURL?.path
    }

    public func append(_ receipt: ConfirmReceipt) throws {
        guard let fileURL else { return }
        var data = try encoder.encode(receipt)
        data.append(contentsOf: [UInt8(ascii: "\n")])
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let handle = try FileHandle(forWritingTo: fileURL)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
        } else {
            try data.write(to: fileURL, options: [.atomic])
        }
    }

    public func recent(limit: Int = 20) throws -> [ConfirmReceipt] {
        guard let fileURL else { return [] }
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let text = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = text.split(whereSeparator: \.isNewline).filter { !$0.isEmpty }
        let slice = lines.suffix(limit)
        return try slice.map { line in
            let data = Data(line.utf8)
            return try decoder.decode(ConfirmReceipt.self, from: data)
        }
    }

    public func count() throws -> Int {
        guard let fileURL, FileManager.default.fileExists(atPath: fileURL.path) else { return 0 }
        let text = try String(contentsOf: fileURL, encoding: .utf8)
        return text.split(whereSeparator: \.isNewline).filter { !$0.isEmpty }.count
    }

    public func reset() throws {
        guard let fileURL else { return }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
