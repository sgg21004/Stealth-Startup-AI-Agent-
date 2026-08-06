import Foundation
import Sensor

/// Redacted, structured context pack sent to the agent brain.
public struct ContextPack: Sendable, Equatable {
    public var app: String
    public var summary: String
    public var cursor: CursorSnapshot
    public var prefsHints: [String]

    public init(app: String, summary: String, cursor: CursorSnapshot, prefsHints: [String] = []) {
        self.app = app
        self.summary = summary
        self.cursor = cursor
        self.prefsHints = prefsHints
    }
}

public enum Redactor: Sendable {
    private static let secretish = [
        "password", "passwd", "passkey", "secret", "token", "cookie",
        "cvv", "ssn", "bearer ", "sk-",
    ]

    public static func redact(_ text: String) -> String {
        var out = text
        for needle in secretish where out.localizedCaseInsensitiveContains(needle) {
            out = "[REDACTED]"
            break
        }
        let digits = out.filter(\.isNumber)
        if digits.count >= 13 && digits.count <= 19 {
            return "[REDACTED_PAN]"
        }
        return out
    }

    public static func redactAll(_ values: [String]) -> [String] {
        values.map(redact)
    }
}

public struct ContextAssembler: Sendable {
    public init() {}

    public func assemble(from snapshot: CursorSnapshot, prefsHints: [String] = []) -> ContextPack {
        let safeHints = Redactor.redactAll(prefsHints)
        return ContextPack(
            app: snapshot.frontmostApp,
            summary: "Focus on \(snapshot.frontmostApp) near cursor (\(Int(snapshot.x)), \(Int(snapshot.y)))",
            cursor: snapshot,
            prefsHints: safeHints
        )
    }
}
