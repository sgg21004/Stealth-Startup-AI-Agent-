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
    public var recordedAt: Date

    public init(
        id: String = UUID().uuidString,
        name: String,
        steps: [String],
        recordedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.steps = steps
        self.recordedAt = recordedAt
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

/// On-disk snapshot. Re-validated on load so never-store stays enforced.
public struct BehaviorSnapshot: Sendable, Codable, Equatable {
    public var version: Int
    public var preferences: [Preference]
    public var playbooks: [Playbook]
    public var skills: [Skill]
    public var updatedAt: Date

    public static let currentVersion = 2

    public init(
        version: Int = BehaviorSnapshot.currentVersion,
        preferences: [Preference] = [],
        playbooks: [Playbook] = [],
        skills: [Skill] = [],
        updatedAt: Date = Date()
    ) {
        self.version = version
        self.preferences = preferences
        self.playbooks = playbooks
        self.skills = skills
        self.updatedAt = updatedAt
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        version = try c.decodeIfPresent(Int.self, forKey: .version) ?? 1
        preferences = try c.decodeIfPresent([Preference].self, forKey: .preferences) ?? []
        playbooks = try c.decodeIfPresent([Playbook].self, forKey: .playbooks) ?? []
        skills = try c.decodeIfPresent([Skill].self, forKey: .skills) ?? []
        updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }
}

public enum BehaviorPaths: Sendable {
    /// `STEALTH_BEHAVIOR_PATH` override, else `~/Library/Application Support/StealthStartup/behavior.json`
    public static func defaultStoreURL() throws -> URL {
        if let override = ProcessInfo.processInfo.environment["STEALTH_BEHAVIOR_PATH"], !override.isEmpty {
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
        return dir.appendingPathComponent("behavior.json", isDirectory: false)
    }
}

/// On-device store for prefs, playbooks, and cross-session skills.
public actor BehaviorStore {
    private var preferences: [Preference] = []
    private var playbooks: [Playbook] = []
    private var skills: [Skill] = []
    private let fileURL: URL?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL? = nil) {
        self.fileURL = fileURL
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func load() throws {
        guard let fileURL else { return }
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            preferences = []
            playbooks = []
            skills = []
            return
        }
        let data = try Data(contentsOf: fileURL)
        let snap = try decoder.decode(BehaviorSnapshot.self, from: data)
        var kept: [Preference] = []
        var dropped = 0
        for pref in snap.preferences {
            switch MemoryPolicy.validate(preference: pref) {
            case .success(let ok):
                kept.append(ok)
            case .failure:
                dropped += 1
            }
        }
        preferences = kept
        playbooks = snap.playbooks
        skills = snap.skills
        if dropped > 0 {
            try persist()
        }
    }

    public func storePath() -> String? {
        fileURL?.path
    }

    @discardableResult
    public func upsert(preference: Preference) throws -> Preference {
        let validated = try MemoryPolicy.validate(preference: preference).get()
        if let idx = preferences.firstIndex(where: { $0.key == validated.key }) {
            preferences[idx] = validated
        } else {
            preferences.append(validated)
        }
        try persist()
        return validated
    }

    public func allPreferences() -> [Preference] {
        preferences
    }

    public func deletePreference(key: String) throws {
        preferences.removeAll { $0.key == key }
        try persist()
    }

    /// Only call after a confirmed successful run.
    public func save(playbook: Playbook) throws {
        playbooks.append(playbook)
        try persist()
    }

    public func allPlaybooks() -> [Playbook] {
        playbooks
    }

    /// Save or replace a skill by trigger (continual learning artifact).
    public func upsert(skill: Skill) throws {
        if let idx = skills.firstIndex(where: { $0.trigger.lowercased() == skill.trigger.lowercased() }) {
            skills[idx] = skill
        } else {
            skills.append(skill)
        }
        try persist()
    }

    public func allSkills() -> [Skill] {
        skills
    }

    /// Retrieve skills without stuffing chat history — substring match on trigger/name.
    public func matchingSkills(query: String, limit: Int = 3) -> [Skill] {
        let q = query.lowercased()
        let hits = skills.filter {
            $0.trigger.lowercased().contains(q)
                || $0.name.lowercased().contains(q)
                || q.contains($0.trigger.lowercased())
        }
        return Array(hits.prefix(limit))
    }

    public func reset() throws {
        preferences = []
        playbooks = []
        skills = []
        try persist()
    }

    public func snapshot() -> BehaviorSnapshot {
        BehaviorSnapshot(
            preferences: preferences,
            playbooks: playbooks,
            skills: skills,
            updatedAt: Date()
        )
    }

    private func persist() throws {
        guard let fileURL else { return }
        let snap = BehaviorSnapshot(
            preferences: preferences,
            playbooks: playbooks,
            skills: skills,
            updatedAt: Date()
        )
        let data = try encoder.encode(snap)
        try data.write(to: fileURL, options: [.atomic])
    }
}
