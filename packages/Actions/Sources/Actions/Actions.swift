import Foundation
import Behavior

public enum ActionOutcome: Sendable, Equatable {
    case confirmedAndRecorded(Playbook)
    case denied
    case dryRun([String])
}

public struct ActionRuntime: Sendable {
    public init() {}

    /// UI driving comes later. v1 records intent as a playbook after confirm.
    public func execute(steps: [String], name: String, confirmed: Bool) -> ActionOutcome {
        guard confirmed else { return .denied }
        let playbook = Playbook(name: name, steps: steps)
        return .confirmedAndRecorded(playbook)
    }

    public func dryRun(steps: [String]) -> ActionOutcome {
        .dryRun(steps)
    }
}
