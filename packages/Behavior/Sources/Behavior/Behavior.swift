import Foundation

public struct Preference: Sendable, Equatable, Codable, Identifiable {
    public var id: String
    public var key: String
    public var value: String

    public init(id: String = UUID().uuidString, key: String, value: String) {
        self.id = id
        self.key = key
        self.value = value
    }
}

public struct Playbook: Sendable, Equatable, Codable, Identifiable {
    public var id: String
    public var name: String
    public var steps: [String]

    public init(id: String = UUID().uuidString, name: String, steps: [String]) {
        self.id = id
        self.name = name
        self.steps = steps
    }
}

/// On-device store for prefs + playbooks. File-backed stub for v1.
public actor BehaviorStore {
    private var preferences: [Preference] = []
    private var playbooks: [Playbook] = []

    public init() {}

    public func upsert(preference: Preference) {
        if let idx = preferences.firstIndex(where: { $0.key == preference.key }) {
            preferences[idx] = preference
        } else {
            preferences.append(preference)
        }
    }

    public func allPreferences() -> [Preference] {
        preferences
    }

    public func save(playbook: Playbook) {
        playbooks.append(playbook)
    }

    public func allPlaybooks() -> [Playbook] {
        playbooks
    }
}
