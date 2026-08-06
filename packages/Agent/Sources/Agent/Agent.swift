import Foundation
import Context
import Behavior

public enum ActionRisk: String, Sendable {
    case suggest
    case click
    case spend
}

public struct ProposedAction: Sendable, Equatable {
    public var title: String
    public var steps: [String]
    public var risk: ActionRisk
    public var needsConfirm: Bool

    public init(title: String, steps: [String], risk: ActionRisk) {
        self.title = title
        self.steps = steps
        self.risk = risk
        self.needsConfirm = risk == .spend || risk == .click
    }
}

public struct AgentBrain: Sendable {
    public init() {}

    /// Cloud-backed planning comes later. For now: heuristic reorder proposal.
    public func propose(from pack: ContextPack, preferences: [Preference]) -> ProposedAction? {
        let looksLikeBrowser = ["Safari", "Chrome", "Arc", "Firefox", "Brave"]
            .contains(where: { pack.app.localizedCaseInsensitiveContains($0) })
        guard looksLikeBrowser else { return nil }

        let vendor = preferences.first(where: { $0.key == "preferred_vendor" })?.value ?? "usual store"
        return ProposedAction(
            title: "Reorder from \(vendor)",
            steps: [
                "Open cart / reorder page",
                "Apply saved prefs",
                "Pause before payment for confirm",
            ],
            risk: .spend
        )
    }
}
