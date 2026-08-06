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
        subcommands: [Session.self, Status.self, Policy.self, Grade.self]
    )
}

struct Status: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Print build/runtime status."
    )

    func run() {
        print("stealth-startup")
        print("host: StealthDesktop (SPM executable stub)")
        print("platform: macOS only")
        print("vertical: browser reorder")
        print("sensing: hotkey session (stub)")
        print("policy: security-memory enforced in Behavior/Agent/Actions")
        print("default session mode: dry-run")
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
        print("planners: untrusted (OpenClaw/cloud); runtime grades plans")
        print("doc: docs/eng/security-memory.md")
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

        var failed = false
        let goodReport = PlanGrader.grade(good)
        printReport(goodReport, source: "fixture:good")
        if !goodReport.passed {
            print("self-test ERROR: good fixture should pass")
            failed = true
        }

        let badCredsReport = PlanGrader.grade(badCreds)
        printReport(badCredsReport, source: "fixture:bad-creds")
        if badCredsReport.passed {
            print("self-test ERROR: bad-creds fixture should fail")
            failed = true
        }

        let badConfirmReport = PlanGrader.grade(badNoConfirm)
        printReport(badConfirmReport, source: "fixture:bad-no-confirm")
        if badConfirmReport.passed {
            print("self-test ERROR: bad-no-confirm fixture should fail")
            failed = true
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
        let store = BehaviorStore()

        // Allowed pref
        _ = try await store.upsert(
            preference: Preference(key: "preferred_vendor", value: "Amazon Subscribe & Save")
        )

        // Demonstrate never-store enforcement
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

        // Bad plan demo (what OpenClaw incorrectly suggested earlier)
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
            await store.save(playbook: playbook)
            print("outcome: recorded playbook '\(playbook.name)' (\(playbook.steps.count) steps)")
        case .policyRejected(let reason):
            print("outcome: policy-rejected (\(reason))")
        }
    }
}
