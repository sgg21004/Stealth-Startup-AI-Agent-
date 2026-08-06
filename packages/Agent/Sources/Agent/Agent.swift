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

    public init(title: String, steps: [String], risk: ActionRisk) {
        self.title = title
        self.steps = steps
        self.risk = risk
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
    case emptyPlan

    public var description: String {
        switch self {
        case .missingSpendConfirm:
            return "reject: spend/checkout plan missing explicit confirm-before-payment step"
        case .credentialMemoryRequested:
            return "reject: plan asks to store or reuse credentials"
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

    public static func validate(_ proposal: ProposedAction) -> Result<ProposedAction, PlanValidationError> {
        guard !proposal.steps.isEmpty else { return .failure(.emptyPlan) }

        let joined = (proposal.steps + [proposal.title]).joined(separator: " ").lowercased()

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

        return .success(proposal)
    }
}

public struct AgentBrain: Sendable {
    public init() {}

    /// Heuristic reorder proposal (cloud planner later). Always includes spend confirm.
    public func propose(from pack: ContextPack, preferences: [Preference]) -> Result<ProposedAction, PlanValidationError> {
        let looksLikeBrowser = ["Safari", "Chrome", "Arc", "Firefox", "Brave"]
            .contains(where: { pack.app.localizedCaseInsensitiveContains($0) })
        guard looksLikeBrowser else {
            return .failure(.emptyPlan)
        }

        let vendor = preferences.first(where: { $0.key == "preferred_vendor" })?.value ?? "usual store"
        let proposal = ProposedAction(
            title: "Reorder from \(vendor)",
            steps: [
                "Open cart / reorder page",
                "Apply saved prefs (never passwords)",
                "Pause before payment for confirm",
            ],
            risk: .spend
        )
        return PlanValidator.validate(proposal)
    }
}
