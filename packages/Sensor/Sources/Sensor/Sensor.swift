import AppKit
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

/// Real frontmost-app + mouse location via AppKit (no Accessibility tree yet).
public actor LocalSensor: Sensing {
    private var active = false

    public init() {}

    public func startSession() async {
        active = true
    }

    public func stopSession() async {
        active = false
    }

    public func snapshot() async -> CursorSnapshot {
        let app = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
        let loc = NSEvent.mouseLocation
        return CursorSnapshot(
            x: loc.x,
            y: loc.y,
            frontmostApp: active ? app : "None"
        )
    }
}

/// Deterministic stub for scripts / CI (`GALAXY_SENSOR=stub`).
public actor StubSensor: Sensing {
    private var active = false
    private let appName: String

    public init(appName: String = "Safari") {
        self.appName = appName
    }

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
            frontmostApp: active ? appName : "None"
        )
    }
}
