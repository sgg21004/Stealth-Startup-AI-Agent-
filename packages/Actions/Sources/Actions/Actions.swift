import Foundation
import Behavior
import Agent

public enum ActionOutcome: Sendable, Equatable {
    case confirmedAndRecorded(Playbook)
    case denied(String)
    case dryRun([String])
    case policyRejected(String)
}

public struct ActionRuntime: Sendable {
    public init() {}

    /// Default path: simulate only. No state change.
    public func dryRun(steps: [String]) -> ActionOutcome {
        .dryRun(steps)
    }

    /// Live path: requires confirm for gated risk classes; records playbook only after confirm.
    public func execute(
        proposal: ProposedAction,
        confirmed: Bool,
        dryRun: Bool
    ) -> ActionOutcome {
        if case .failure(let err) = PlanValidator.validate(proposal) {
            return .policyRejected(err.description)
        }

        if dryRun {
            return .dryRun(proposal.steps)
        }

        if proposal.needsConfirm && !confirmed {
            return .denied("needs confirm for risk=\(proposal.risk.rawValue)")
        }

        switch proposal.risk {
        case .spend, .send, .delete, .auth:
            guard confirmed else {
                return .denied("hard gate: \(proposal.risk.rawValue) always requires confirm")
            }
        case .observe, .suggest, .navigate, .fill:
            break
        }

        let playbook = Playbook(name: proposal.title, steps: proposal.steps)
        return .confirmedAndRecorded(playbook)
    }
}
