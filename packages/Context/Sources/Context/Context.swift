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

public struct ContextAssembler: Sendable {
    public init() {}

    public func assemble(from snapshot: CursorSnapshot, prefsHints: [String] = []) -> ContextPack {
        ContextPack(
            app: snapshot.frontmostApp,
            summary: "Focus on \(snapshot.frontmostApp) near cursor (\(Int(snapshot.x)), \(Int(snapshot.y)))",
            cursor: snapshot,
            prefsHints: prefsHints
        )
    }
}
