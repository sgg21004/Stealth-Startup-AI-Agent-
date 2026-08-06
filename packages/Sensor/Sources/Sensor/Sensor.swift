import Foundation

/// Captures cursor/focus signals during an opt-in attention session.
public struct CursorSnapshot: Sendable, Equatable {
    public var x: Double
    public var y: Double
    public var frontmostApp: String
    public var timestamp: Date

    public init(x: Double, y: Double, frontmostApp: String, timestamp: Date = Date()) {
        self.x = x
        self.y = y
        self.frontmostApp = frontmostApp
        self.timestamp = timestamp
    }
}

public protocol Sensing: Sendable {
    func startSession() async
    func stopSession() async
    func snapshot() async -> CursorSnapshot
}

/// Stub sensor for CLI/dev until Accessibility APIs are wired in the macOS app host.
public actor StubSensor: Sensing {
    private var active = false

    public init() {}

    public func startSession() async {
        active = true
    }

    public func stopSession() async {
        active = false
    }

    public func snapshot() async -> CursorSnapshot {
        CursorSnapshot(
            x: 0,
            y: 0,
            frontmostApp: active ? "Safari" : "None"
        )
    }
}
