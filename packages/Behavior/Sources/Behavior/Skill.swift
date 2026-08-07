import Foundation

/// Compact cross-session cheat sheet. Not chat history — a retrievable skill card.
public struct Skill: Sendable, Equatable, Codable, Identifiable {
    public var id: String
    public var name: String
    /// Simple match string (e.g. vendor or app hint). Not embeddings (yet).
    public var trigger: String
    public var steps: [String]
    public var risk: String
    public var sourcePlaybookId: String?
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        name: String,
        trigger: String,
        steps: [String],
        risk: String,
        sourcePlaybookId: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.trigger = trigger
        self.steps = steps
        self.risk = risk
        self.sourcePlaybookId = sourcePlaybookId
        self.createdAt = createdAt
    }

    /// Tiny context injection — continual learning without stuffing old chats.
    public func contextCard() -> String {
        var lines: [String] = []
        lines.append("SKILL: \(name)")
        lines.append("trigger: \(trigger)")
        lines.append("risk: \(risk)")
        lines.append("steps:")
        for (i, step) in steps.enumerated() {
            lines.append("  \(i + 1). \(step)")
        }
        return lines.joined(separator: "\n")
    }

    public var approxTokens: Int {
        max(1, contextCard().count / 4)
    }
}

public enum SkillDistiller: Sendable {
    /// Turn a confirmed playbook into a durable skill card.
    public static func distill(
        playbook: Playbook,
        trigger: String,
        risk: String = "spend"
    ) -> Skill {
        Skill(
            name: playbook.name,
            trigger: trigger,
            steps: playbook.steps,
            risk: risk,
            sourcePlaybookId: playbook.id
        )
    }
}
