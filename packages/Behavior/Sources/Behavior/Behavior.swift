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

public enum MemoryWriteError: Error, Sendable, Equatable {
    case neverStoreKey(String)
    case neverStoreValue
}

/// Hard bans from docs/eng/security-memory.md
public enum MemoryPolicy: Sendable {
    private static let bannedKeyFragments = [
        "password", "passwd", "passkey", "secret", "token", "cookie",
        "session", "credential", "api_key", "apikey", "auth",
        "card", "cvv", "ssn", "bank",
    ]

    private static let bannedValuePatterns = [
        "password", "passwd", "sk-", "Bearer ", "cvv",
    ]

    public static func validate(preference: Preference) -> Result<Preference, MemoryWriteError> {
        let key = preference.key.lowercased()
        if bannedKeyFragments.contains(where: { key.contains($0) }) {
            return .failure(.neverStoreKey(preference.key))
        }
        let value = preference.value
        if bannedValuePatterns.contains(where: { value.localizedCaseInsensitiveContains($0) }) {
            return .failure(.neverStoreValue)
        }
        // Crude PAN-looking digit runs (13–19 digits)
        let digits = value.filter(\.isNumber)
        if digits.count >= 13 && digits.count <= 19 {
            return .failure(.neverStoreValue)
        }
        return .success(preference)
    }
}

/// On-device store for prefs + playbooks. Enforces never-store policy on write.
public actor BehaviorStore {
    private var preferences: [Preference] = []
    private var playbooks: [Playbook] = []

    public init() {}

    @discardableResult
    public func upsert(preference: Preference) throws -> Preference {
        let validated = try MemoryPolicy.validate(preference: preference).get()
        if let idx = preferences.firstIndex(where: { $0.key == validated.key }) {
            preferences[idx] = validated
        } else {
            preferences.append(validated)
        }
        return validated
    }

    public func allPreferences() -> [Preference] {
        preferences
    }

    public func deletePreference(key: String) {
        preferences.removeAll { $0.key == key }
    }

    /// Only call after a confirmed successful run.
    public func save(playbook: Playbook) {
        playbooks.append(playbook)
    }

    public func allPlaybooks() -> [Playbook] {
        playbooks
    }
}
