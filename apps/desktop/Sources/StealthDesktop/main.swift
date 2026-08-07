import ArgumentParser
import Foundation
import Sensor
import Context
import Agent
import Actions
import Behavior

@main
struct StealthDesktop: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "StealthDesktop",
        abstract: "macOS cursor agent host (CLI stub until Xcode app target lands).",
        subcommands: [Session.self, Status.self, Policy.self, Grade.self, Memory.self, Audit.self, Skills.self]
    )
}

struct Status: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Print build/runtime status."
    )

    func run() async throws {
        let url = try BehaviorPaths.defaultStoreURL()
        let store = BehaviorStore(fileURL: url)
        try await store.load()
        let snap = await store.snapshot()

        print("stealth-startup")
        print("host: StealthDesktop (SPM executable stub)")
        print("platform: macOS only")
        print("vertical: browser reorder")
        let sensorMode = ProcessInfo.processInfo.environment["STEALTH_SENSOR"] == "stub" ? "stub" : "local"
        print("sensing: \(sensorMode) (frontmost app + mouse; a11y tree later)")
        print("policy: security-memory enforced in Behavior/Agent/Actions")
        print("default session mode: dry-run")
        print("propose: skill cards first, heuristic fallback")
        let auditURL = try AuditPaths.defaultAuditURL()
        let audit = AuditLog(fileURL: auditURL)
        let auditCount = try await audit.count()

        print("memory.path: \(url.path)")
        print("memory.prefs: \(snap.preferences.count)")
        print("memory.playbooks: \(snap.playbooks.count)")
        print("memory.skills: \(snap.skills.count)")
        print("audit.path: \(auditURL.path)")
        print("audit.receipts: \(auditCount)")
        print("continual-learning: docs/eng/continual-learning.md")
    }
}

struct Policy: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show security/memory hard rules."
    )

    func run() {
        print("never-store: passwords, tokens, cookies, cards, CVV, SSN")
        print("always-confirm: spend, send, delete, auth")
        print("memory: on-device prefs/playbooks after confirmed success only")
        print("memory.path: ~/Library/Application Support/StealthStartup/behavior.json")
        print("audit.path: ~/Library/Application Support/StealthStartup/audit.jsonl")
        print("planners: untrusted (OpenClaw/cloud); runtime grades plans")
        print("doc: docs/eng/security-memory.md")
    }
}

struct Audit: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "audit",
        abstract: "Inspect confirm receipts (scrutiny trail).",
        subcommands: [Show.self, Reset.self]
    )

    struct Show: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Print recent confirm receipts."
        )

        @Option(name: .long, help: "Max receipts to show.")
        var limit: Int = 20

        func run() async throws {
            let url = try AuditPaths.defaultAuditURL()
            let log = AuditLog(fileURL: url)
            let rows = try await log.recent(limit: limit)
            print("path: \(url.path)")
            print("showing: \(rows.count)")
            for r in rows {
                let detail = r.detail.map { " detail=\($0)" } ?? ""
                print(
                    "- \(r.at) mode=\(r.mode) outcome=\(r.outcome) risk=\(r.risk) confirmed=\(r.userConfirmed) title=\(r.title)\(detail)"
                )
            }
        }
    }

    struct Reset: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Wipe audit.jsonl."
        )

        func run() async throws {
            let url = try AuditPaths.defaultAuditURL()
            let log = AuditLog(fileURL: url)
            try await log.reset()
            print("audit: reset \(url.path)")
        }
    }
}

struct Memory: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "memory",
        abstract: "Inspect or reset on-device Behavior store.",
        subcommands: [Show.self, Reset.self]
    )

    struct Show: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Print prefs + playbooks from disk."
        )

        func run() async throws {
            let url = try BehaviorPaths.defaultStoreURL()
            let store = BehaviorStore(fileURL: url)
            try await store.load()
            let snap = await store.snapshot()
            print("path: \(url.path)")
            print("prefs: \(snap.preferences.count)")
            for p in snap.preferences {
                print("  - \(p.key)=\(p.value)")
            }
            print("playbooks: \(snap.playbooks.count)")
            for pb in snap.playbooks {
                print("  - \(pb.name) (\(pb.steps.count) steps)")
            }
            print("skills: \(snap.skills.count)")
            for s in snap.skills {
                print("  - \(s.name) trigger=\(s.trigger) ~\(s.approxTokens) tok")
            }
        }
    }

    struct Reset: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Wipe on-device prefs + playbooks + skills."
        )

        func run() async throws {
            let url = try BehaviorPaths.defaultStoreURL()
            let store = BehaviorStore(fileURL: url)
            try await store.load()
            try await store.reset()
            print("memory: reset \(url.path)")
        }
    }
}

struct Grade: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Grade an untrusted planner JSON plan against security-memory policy."
    )

    @Option(name: .long, help: "Path to plan JSON ({title,steps,risk,prefs_to_remember}).")
    var file: String?

    @Flag(name: .long, help: "Read plan JSON from stdin.")
    var stdin: Bool = false

    @Flag(name: .long, help: "Run built-in pass/fail fixtures (no OpenClaw).")
    var selfTest: Bool = false

    func run() throws {
        if selfTest {
            try runSelfTest()
            return
        }

        let data: Data
        if stdin {
            data = FileHandle.standardInput.readDataToEndOfFile()
        } else if let file {
            data = try Data(contentsOf: URL(fileURLWithPath: file))
        } else {
            throw ValidationError("Pass --file, --stdin, or --self-test")
        }

        let draft = try PlanGrader.decodeDraft(from: data)
        let report = PlanGrader.grade(draft)
        printReport(report, source: file ?? "stdin")
        if !report.passed {
            throw ExitCode(2)
        }
    }

    private func runSelfTest() throws {
        let good = PlanDraft(
            title: "Reorder from Amazon Subscribe & Save",
            steps: [
                "Open cart / reorder page",
                "Apply saved prefs (never passwords)",
                "Pause before payment for confirm",
            ],
            risk: .spend,
            prefsToRemember: ["preferred_vendor=Amazon Subscribe & Save"]
        )
        let badCreds = PlanDraft(
            title: "Reorder and save login credentials",
            steps: ["Open Amazon", "Reuse password", "Place order"],
            risk: .spend,
            prefsToRemember: ["Store Amazon login credentials"]
        )
        let badNoConfirm = PlanDraft(
            title: "Buy coffee pods",
            steps: ["Open cart", "Place order and pay"],
            risk: .spend,
            prefsToRemember: []
        )
        let badTheater = PlanDraft(
            title: "Reorder coffee pods",
            steps: ["Open Subscribe & Save", "Place order and pay", "No confirmation needed for any step"],
            risk: .spend,
            prefsToRemember: []
        )
        let badAlwaysOn = PlanDraft(
            title: "Watch shopping habits",
            steps: ["Enable always-on screen capture", "Learn reorder patterns"],
            risk: .observe,
            prefsToRemember: []
        )
        let badConfirmAfterSpend = PlanDraft(
            title: "Checkout then maybe confirm",
            steps: [
                "Open cart",
                "Place order and pay",
                "Confirm the receipt was emailed",
            ],
            risk: .spend,
            prefsToRemember: []
        )

        var failed = false
        let cases: [(String, PlanDraft, Bool)] = [
            ("good", good, true),
            ("bad-creds", badCreds, false),
            ("bad-no-confirm", badNoConfirm, false),
            ("bad-theater", badTheater, false),
            ("bad-always-on", badAlwaysOn, false),
            ("bad-confirm-after-spend", badConfirmAfterSpend, false),
        ]

        for (name, draft, shouldPass) in cases {
            let report = PlanGrader.grade(draft)
            printReport(report, source: "fixture:\(name)")
            if report.passed != shouldPass {
                print("self-test ERROR: \(name) expected \(shouldPass ? "PASS" : "FAIL")")
                failed = true
            }
        }

        if failed {
            throw ExitCode(1)
        }
        print("self-test: PASS")
    }

    private func printReport(_ report: GradeReport, source: String) {
        print("grade: \(report.passed ? "PASS" : "FAIL") source=\(source)")
        print("title: \(report.title)")
        print("steps: \(report.stepCount)")
        if report.failures.isEmpty {
            print("failures: none")
        } else {
            print("failures:")
            for f in report.failures {
                print("  - \(f)")
            }
        }
    }
}

struct Skills: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "skills",
        abstract: "Cross-session skill cards (continual learning).",
        subcommands: [List.self, Add.self, RetainCheck.self]
    )

    struct List: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Print skill cards from disk."
        )

        func run() async throws {
            let url = try BehaviorPaths.defaultStoreURL()
            let store = BehaviorStore(fileURL: url)
            try await store.load()
            let skills = await store.allSkills()
            print("path: \(url.path)")
            print("skills: \(skills.count)")
            for s in skills {
                print("---")
                print(s.contextCard())
                print("approx_tokens: \(s.approxTokens)")
            }
        }
    }

    struct Add: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Add a skill card (research / second-task demos)."
        )

        @Option(name: .long, help: "Skill name.")
        var name: String

        @Option(name: .long, help: "Trigger string used for retrieve.")
        var trigger: String

        @Option(name: .long, help: "Risk class string (default: spend).")
        var risk: String = "spend"

        @Option(name: .long, parsing: .singleValue, help: "Step (repeat flag for multiple).")
        var step: [String]

        func run() async throws {
            guard !step.isEmpty else {
                throw ValidationError("Pass at least one --step")
            }
            let url = try BehaviorPaths.defaultStoreURL()
            let store = BehaviorStore(fileURL: url)
            try await store.load()
            let skill = Skill(name: name, trigger: trigger, steps: step, risk: risk)
            try await store.upsert(skill: skill)
            print("skills: saved '\(skill.name)' trigger=\(skill.trigger) ~\(skill.approxTokens) tok")
            print("path: \(url.path)")
        }
    }

    struct RetainCheck: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Check that listed triggers still retrieve (A then B retention)."
        )

        @Option(name: .long, parsing: .singleValue, help: "Trigger to retrieve (repeat).")
        var trigger: [String]

        func run() async throws {
            guard !trigger.isEmpty else {
                throw ValidationError("Pass at least one --trigger")
            }
            let url = try BehaviorPaths.defaultStoreURL()
            let store = BehaviorStore(fileURL: url)
            try await store.load()
            var failed = false
            for t in trigger {
                let hits = await store.matchingSkills(query: t, limit: 3)
                let ok = !hits.isEmpty
                print("retain: trigger=\(t) hits=\(hits.count) \(ok ? "PASS" : "FAIL")")
                for h in hits {
                    print("  - \(h.name) ~\(h.approxTokens) tok")
                }
                if !ok { failed = true }
            }
            let all = await store.allSkills()
            print("skills.total: \(all.count)")
            if failed {
                throw ExitCode(2)
            }
            print("retain-check: PASS")
        }
    }
}

struct Session: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Run one opt-in attention session (dry-run by default)."
    )

    @Flag(name: .long, help: "Record playbook after policy checks (still requires confirm for spend).")
    var live: Bool = false

    @Flag(name: .long, help: "Pre-approve gated actions (scripts/CI). Otherwise live mode prompts on a TTY.")
    var confirm: Bool = false

    @Option(name: .long, help: "Override sensed frontmost app (e.g. Safari) when the CLI isn't focused on a browser.")
    var assumeApp: String?

    func run() async throws {
        let useStub = ProcessInfo.processInfo.environment["STEALTH_SENSOR"] == "stub"
        let assembler = ContextAssembler()
        let brain = AgentBrain()
        let runtime = ActionRuntime()

        let url = try BehaviorPaths.defaultStoreURL()
        let store = BehaviorStore(fileURL: url)
        try await store.load()
        print("memory: loaded \(url.path)")

        let auditURL = try AuditPaths.defaultAuditURL()
        let audit = AuditLog(fileURL: auditURL)
        print("audit: \(auditURL.path)")

        // Seed vendor pref if missing (allowed)
        if await store.allPreferences().contains(where: { $0.key == "preferred_vendor" }) == false {
            _ = try await store.upsert(
                preference: Preference(key: "preferred_vendor", value: "Amazon Subscribe & Save")
            )
            print("memory: seeded preferred_vendor")
        }

        // Demonstrate never-store enforcement (must not persist)
        do {
            _ = try await store.upsert(
                preference: Preference(key: "amazon_password", value: "demo-should-fail")
            )
            print("policy: ERROR never-store failed to block password key")
        } catch {
            print("policy: blocked secret memory write (\(error))")
        }

        let snapshot: CursorSnapshot
        let sensorLabel: String
        if useStub {
            let sensor = StubSensor()
            await sensor.startSession()
            let raw = await sensor.snapshot()
            await sensor.stopSession()
            snapshot = Self.applyAssumeApp(raw, assumeApp: assumeApp)
            sensorLabel = "stub"
        } else {
            let sensor = LocalSensor()
            await sensor.startSession()
            let raw = await sensor.snapshot()
            await sensor.stopSession()
            snapshot = Self.applyAssumeApp(raw, assumeApp: assumeApp)
            sensorLabel = "local"
        }

        let prefs = await store.allPreferences()
        let vendor = prefs.first(where: { $0.key == "preferred_vendor" })?.value ?? "reorder"
        // Continual learning: retrieve skill cards for this process — no prior chat history.
        let matched = await store.matchingSkills(query: vendor, limit: 3)
        let cards = matched.map { $0.contextCard() }
        let tok = matched.reduce(0) { $0 + $1.approxTokens }
        let pack = assembler.assemble(
            from: snapshot,
            prefsHints: prefs.map(\.value),
            skillCards: cards,
            skillTokensApprox: tok
        )

        print("session:on app=\(pack.app) mode=\(live ? "live" : "dry-run") sensor=\(sensorLabel)")
        print("context: \(pack.summary)")
        print("memory.prefs: \(prefs.count)")
        print("skills.retrieved: \(matched.count) approx_tokens=\(tok) (not chat history)")
        for s in matched {
            print("skills.hit: \(s.name) trigger=\(s.trigger)")
        }

        let proposal: ProposedAction
        switch brain.propose(from: pack, preferences: prefs, skills: matched) {
        case .failure(let err):
            print("proposal: \(err)")
            print("hint: focus a browser, pass --assume-app Safari, or STEALTH_SENSOR=stub")
            return
        case .success(let value):
            proposal = value
        }

        print("proposal: \(proposal.title) risk=\(proposal.risk.rawValue)")
        print("proposal.origin: \(proposal.origin)")
        for (i, step) in proposal.steps.enumerated() {
            print("  \(i + 1). \(step)")
        }
        print("needsConfirm: \(proposal.needsConfirm)")

        let bad = ProposedAction(
            title: "Reorder and save login credentials",
            steps: ["Open Amazon", "Reuse password", "Place order"],
            risk: .spend
        )
        if case .failure(let err) = PlanValidator.validate(bad) {
            print("scrutiny: rejected untrusted plan (\(err))")
        }

        let userConfirmed: Bool
        if !live {
            userConfirmed = false
        } else if proposal.needsConfirm {
            userConfirmed = try Self.resolveConfirm(proposal: proposal, flagConfirm: confirm, app: pack.app)
            if !userConfirmed {
                print("outcome: denied (user refused confirm)")
                try await audit.append(
                    ConfirmReceipt(
                        mode: "live",
                        outcome: "denied",
                        title: proposal.title,
                        risk: proposal.risk.rawValue,
                        steps: proposal.steps,
                        userConfirmed: false,
                        detail: "user refused confirm"
                    )
                )
                print("audit: receipt written")
                return
            }
        } else {
            userConfirmed = true
        }

        let outcome = runtime.execute(
            proposal: proposal,
            confirmed: userConfirmed,
            dryRun: !live
        )

        let mode = live ? "live" : "dry-run"
        switch outcome {
        case .denied(let reason):
            print("outcome: denied (\(reason))")
            try await audit.append(
                ConfirmReceipt(
                    mode: mode,
                    outcome: "denied",
                    title: proposal.title,
                    risk: proposal.risk.rawValue,
                    steps: proposal.steps,
                    userConfirmed: userConfirmed,
                    detail: reason
                )
            )
            print("audit: receipt written")
        case .dryRun(let steps):
            print("outcome: dry-run \(steps.count) steps (pass --live; confirm on TTY or --confirm)")
            try await audit.append(
                ConfirmReceipt(
                    mode: mode,
                    outcome: "dry-run",
                    title: proposal.title,
                    risk: proposal.risk.rawValue,
                    steps: steps,
                    userConfirmed: false,
                    detail: "origin:\(proposal.origin)"
                )
            )
        case .confirmedAndRecorded(let playbook):
            try await store.save(playbook: playbook)
            let skill = SkillDistiller.distill(
                playbook: playbook,
                trigger: vendor,
                risk: proposal.risk.rawValue
            )
            try await store.upsert(skill: skill)
            print("outcome: recorded playbook '\(playbook.name)' (\(playbook.steps.count) steps)")
            print("skills: saved '\(skill.name)' trigger=\(skill.trigger) ~\(skill.approxTokens) tok")
            print("memory: persisted")
            try await audit.append(
                ConfirmReceipt(
                    mode: mode,
                    outcome: "confirmed",
                    title: proposal.title,
                    risk: proposal.risk.rawValue,
                    steps: proposal.steps,
                    userConfirmed: userConfirmed,
                    detail: "playbook:\(playbook.id);skill:\(skill.id);origin:\(proposal.origin)"
                )
            )
            print("audit: receipt written")
        case .policyRejected(let reason):
            print("outcome: policy-rejected (\(reason))")
            try await audit.append(
                ConfirmReceipt(
                    mode: mode,
                    outcome: "policy-rejected",
                    title: proposal.title,
                    risk: proposal.risk.rawValue,
                    steps: proposal.steps,
                    userConfirmed: userConfirmed,
                    detail: reason
                )
            )
            print("audit: receipt written")
        }
    }

    private static func applyAssumeApp(_ snap: CursorSnapshot, assumeApp: String?) -> CursorSnapshot {
        let env = ProcessInfo.processInfo.environment["STEALTH_ASSUME_APP"]
        let name = (assumeApp?.isEmpty == false ? assumeApp : nil) ?? (env?.isEmpty == false ? env : nil)
        guard let name else { return snap }
        return CursorSnapshot(x: snap.x, y: snap.y, frontmostApp: name, timestamp: snap.timestamp)
    }

    /// Interactive confirm: shows what / where / risk / steps. `--confirm` or STEALTH_ASSUME_YES=1 for scripts.
    private static func resolveConfirm(proposal: ProposedAction, flagConfirm: Bool, app: String) throws -> Bool {
        if flagConfirm { return true }
        if ProcessInfo.processInfo.environment["STEALTH_ASSUME_YES"] == "1" { return true }

        guard isatty(fileno(stdin)) != 0 else {
            print("confirm: non-TTY — pass --confirm or STEALTH_ASSUME_YES=1")
            return false
        }

        print("── confirm ──")
        print("what: \(proposal.title)")
        print("where: \(app)")
        print("risk: \(proposal.risk.rawValue)")
        print("origin: \(proposal.origin)")
        for (i, step) in proposal.steps.enumerated() {
            print("  \(i + 1). \(step)")
        }
        print("Proceed? [y/N] ", terminator: "")
        guard let line = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else {
            return false
        }
        return line == "y" || line == "yes"
    }
}
