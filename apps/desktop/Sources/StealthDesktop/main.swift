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
        subcommands: [Session.self, Status.self, Policy.self, Grade.self, Memory.self]
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
        print("sensing: hotkey session (stub)")
        print("policy: security-memory enforced in Behavior/Agent/Actions")
        print("default session mode: dry-run")
        print("memory.path: \(url.path)")
        print("memory.prefs: \(snap.preferences.count)")
        print("memory.playbooks: \(snap.playbooks.count)")
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
        print("planners: untrusted (OpenClaw/cloud); runtime grades plans")
        print("doc: docs/eng/security-memory.md")
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
        }
    }

    struct Reset: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Wipe on-device prefs + playbooks."
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

        var failed = false
        let cases: [(String, PlanDraft, Bool)] = [
            ("good", good, true),
            ("bad-creds", badCreds, false),
            ("bad-no-confirm", badNoConfirm, false),
            ("bad-theater", badTheater, false),
            ("bad-always-on", badAlwaysOn, false),
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

struct Session: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Run one opt-in attention session (dry-run by default)."
    )

    @Flag(name: .long, help: "Record playbook after policy checks (still requires --confirm for spend).")
    var live: Bool = false

    @Flag(name: .long, help: "User confirm for gated actions (spend/send/delete/auth).")
    var confirm: Bool = false

    func run() async throws {
        let sensor = StubSensor()
        let assembler = ContextAssembler()
        let brain = AgentBrain()
        let runtime = ActionRuntime()

        let url = try BehaviorPaths.defaultStoreURL()
        let store = BehaviorStore(fileURL: url)
        try await store.load()
        print("memory: loaded \(url.path)")

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

        await sensor.startSession()
        defer {
            Task { await sensor.stopSession() }
        }

        let snapshot = await sensor.snapshot()
        let prefs = await store.allPreferences()
        let pack = assembler.assemble(from: snapshot, prefsHints: prefs.map(\.value))

        print("session:on app=\(pack.app) mode=\(live ? "live" : "dry-run")")
        print("context: \(pack.summary)")
        print("memory.prefs: \(prefs.count)")

        let proposal: ProposedAction
        switch brain.propose(from: pack, preferences: prefs) {
        case .failure(let err):
            print("proposal: \(err)")
            return
        case .success(let value):
            proposal = value
        }

        print("proposal: \(proposal.title) risk=\(proposal.risk.rawValue)")
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

        let outcome = runtime.execute(
            proposal: proposal,
            confirmed: confirm,
            dryRun: !live
        )

        switch outcome {
        case .denied(let reason):
            print("outcome: denied (\(reason))")
        case .dryRun(let steps):
            print("outcome: dry-run \(steps.count) steps (pass --live --confirm to record)")
        case .confirmedAndRecorded(let playbook):
            try await store.save(playbook: playbook)
            print("outcome: recorded playbook '\(playbook.name)' (\(playbook.steps.count) steps)")
            print("memory: persisted")
        case .policyRejected(let reason):
            print("outcome: policy-rejected (\(reason))")
        }
    }
}
