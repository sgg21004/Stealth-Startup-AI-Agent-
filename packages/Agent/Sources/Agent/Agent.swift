import Foundation
import Context
import Behavior

public enum ActionRisk: String, Sendable, Codable {
    case observe
    case suggest
    case navigate
    case fill
    case spend
    case send
    case delete
    case auth
}

public struct ProposedAction: Sendable, Equatable {
    public var title: String
    public var steps: [String]
    public var risk: ActionRisk
    public var needsConfirm: Bool
    /// `heuristic` or `skill:<name>` — proves continual learning changed the plan.
    public var origin: String

    public init(title: String, steps: [String], risk: ActionRisk, origin: String = "heuristic") {
        self.title = title
        self.steps = steps
        self.risk = risk
        self.origin = origin
        switch risk {
        case .spend, .send, .delete, .auth, .fill, .navigate:
            self.needsConfirm = true
        case .observe, .suggest:
            self.needsConfirm = false
        }
    }
}

public enum PlanValidationError: Error, Sendable, Equatable, CustomStringConvertible {
    case missingSpendConfirm
    case credentialMemoryRequested
    case confirmTheater
    case alwaysOnCapture
    case graphInvalid(String)
    case emptyPlan

    public var description: String {
        switch self {
        case .missingSpendConfirm:
            return "reject: spend/checkout plan missing explicit confirm-before-payment step"
        case .credentialMemoryRequested:
            return "reject: plan asks to store or reuse credentials"
        case .confirmTheater:
            return "reject: plan claims confirmation is unnecessary for spend/side effects"
        case .alwaysOnCapture:
            return "reject: plan requests always-on / continuous screen capture"
        case .graphInvalid(let detail):
            return detail
        case .emptyPlan:
            return "reject: empty plan"
        }
    }
}

/// Grades untrusted planner output against security-memory policy.
public enum PlanValidator: Sendable {
    private static let spendSignals = ["pay", "payment", "checkout", "place order", "purchase", "buy"]
    private static let confirmSignals = ["confirm", "pause before payment", "ask user", "approval"]
    private static let credentialSignals = [
        "login credentials", "save password", "remember password",
        "reuse password", "store password", "store token",
        "session cookie", "save login", "store credentials",
        "remember credentials",
    ]
    private static let theaterSignals = [
        "no confirmation needed", "no confirm needed", "none of the steps require",
        "without confirmation", "skip confirmation", "don't ask the user",
        "do not ask the user", "no user confirmation",
    ]
    private static let alwaysOnSignals = [
        "always-on", "always on", "continuous screen", "continuously capture",
        "record the screen all day", "background screen recording",
    ]

    public static func validate(_ proposal: ProposedAction) -> Result<ProposedAction, PlanValidationError> {
        guard !proposal.steps.isEmpty else { return .failure(.emptyPlan) }

        let joined = (proposal.steps + [proposal.title]).joined(separator: " ").lowercased()

        if alwaysOnSignals.contains(where: { joined.contains($0) }) {
            return .failure(.alwaysOnCapture)
        }

        if theaterSignals.contains(where: { joined.contains($0) }) {
            return .failure(.confirmTheater)
        }

        // Allow explicit "no credentials/passwords" wording; ban store/reuse intent.
        let negated = joined.contains("no password") || joined.contains("never password")
            || joined.contains("no credential") || joined.contains("without credential")
        if !negated && credentialSignals.contains(where: { joined.contains($0) }) {
            return .failure(.credentialMemoryRequested)
        }

        if proposal.risk == .spend || spendSignals.contains(where: { joined.contains($0) }) {
            let hasConfirm = confirmSignals.contains(where: { joined.contains($0) })
            if !hasConfirm || !proposal.needsConfirm {
                return .failure(.missingSpendConfirm)
            }
        }

        // Structural gate: irreversible nodes need a confirm *predecessor* (not after).
        let graph = PlaybookGraphBuilder.linear(from: proposal.steps)
        if case .failure(let err) = PlaybookGraphValidator.validate(graph) {
            return .failure(.graphInvalid(err.description))
        }

        return .success(proposal)
    }
}

public struct AgentBrain: Sendable {
    public init() {}

    /// Prefer retrieved skill cards (validated); else heuristic reorder. Planners stay untrusted.
    public func propose(
        from pack: ContextPack,
        preferences: [Preference],
        skills: [Skill] = []
    ) -> Result<ProposedAction, PlanValidationError> {
        let looksLikeBrowser = ["Safari", "Chrome", "Arc", "Firefox", "Brave"]
            .contains(where: { pack.app.localizedCaseInsensitiveContains($0) })
        guard looksLikeBrowser else {
            return .failure(.emptyPlan)
        }

        for skill in skills where !skill.steps.isEmpty {
            let risk = ActionRisk(rawValue: skill.risk) ?? .spend
            let fromSkill = ProposedAction(
                title: skill.name,
                steps: skill.steps,
                risk: risk,
                origin: "skill:\(skill.name)"
            )
            if case .success(let ok) = PlanValidator.validate(fromSkill) {
                return .success(ok)
            }
        }

        let vendor = preferences.first(where: { $0.key == "preferred_vendor" })?.value ?? "usual store"
        let proposal = ProposedAction(
            title: "Reorder from \(vendor)",
            steps: [
                "Open cart / reorder page",
                "Apply saved prefs (never passwords)",
                "Pause before payment for confirm",
            ],
            risk: .spend,
            origin: "heuristic"
        )
        return PlanValidator.validate(proposal)
    }
}
