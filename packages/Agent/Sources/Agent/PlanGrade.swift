import Foundation
import Behavior

/// External planner payload (OpenClaw / cloud). Untrusted.
public struct PlanDraft: Sendable, Codable, Equatable {
    public var title: String
    public var steps: [String]
    public var risk: ActionRisk
    public var prefsToRemember: [String]

    public enum CodingKeys: String, CodingKey {
        case title, steps, risk
        case prefsToRemember = "prefs_to_remember"
    }

    public init(
        title: String,
        steps: [String],
        risk: ActionRisk = .spend,
        prefsToRemember: [String] = []
    ) {
        self.title = title
        self.steps = steps
        self.risk = risk
        self.prefsToRemember = prefsToRemember
    }

    public func asProposedAction() -> ProposedAction {
        ProposedAction(title: title, steps: steps, risk: risk)
    }
}

public struct GradeReport: Sendable, Equatable {
    public var passed: Bool
    public var failures: [String]
    public var title: String
    public var stepCount: Int

    public init(passed: Bool, failures: [String], title: String, stepCount: Int) {
        self.passed = passed
        self.failures = failures
        self.title = title
        self.stepCount = stepCount
    }
}

public enum PlanGrader: Sendable {
    public static func grade(_ draft: PlanDraft) -> GradeReport {
        var failures: [String] = []

        switch PlanValidator.validate(draft.asProposedAction()) {
        case .success:
            break
        case .failure(let err):
            failures.append(err.description)
        }

        for pref in draft.prefsToRemember {
            let candidate = Preference(key: prefKey(from: pref), value: pref)
            if case .failure(let err) = MemoryPolicy.validate(preference: candidate) {
                failures.append("prefs_to_remember blocked: \(err)")
            }
            let lower = pref.lowercased()
            if lower.contains("password") || lower.contains("credential") || lower.contains("login") {
                failures.append("prefs_to_remember looks like a secret/login hint: \(pref)")
            }
        }

        return GradeReport(
            passed: failures.isEmpty,
            failures: failures,
            title: draft.title,
            stepCount: draft.steps.count
        )
    }

    public static func decodeDraft(from data: Data) throws -> PlanDraft {
        let decoder = JSONDecoder()
        return try decoder.decode(PlanDraft.self, from: data)
    }

    private static func prefKey(from value: String) -> String {
        let slug = value
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .prefix(48)
        return "pref_\(slug)"
    }
}
