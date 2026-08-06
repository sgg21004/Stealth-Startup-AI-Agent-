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
        subcommands: [Session.self, Status.self]
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
        print("models: cloud later; heuristic brain now")
    }
}

struct Session: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Run one opt-in attention session (stub loop)."
    )

    @Flag(name: .long, help: "Auto-confirm the proposed action (dev only).")
    var confirm: Bool = false

    func run() async throws {
        let sensor = StubSensor()
        let assembler = ContextAssembler()
        let brain = AgentBrain()
        let runtime = ActionRuntime()
        let store = BehaviorStore()

        await store.upsert(preference: Preference(key: "preferred_vendor", value: "Amazon Subscribe & Save"))
        await sensor.startSession()
        defer {
            Task { await sensor.stopSession() }
        }

        let snapshot = await sensor.snapshot()
        let prefs = await store.allPreferences()
        let pack = assembler.assemble(from: snapshot, prefsHints: prefs.map(\.value))

        print("session:on app=\(pack.app)")
        print("context: \(pack.summary)")

        guard let proposal = brain.propose(from: pack, preferences: prefs) else {
            print("proposal: none")
            return
        }

        print("proposal: \(proposal.title)")
        for (i, step) in proposal.steps.enumerated() {
            print("  \(i + 1). \(step)")
        }
        print("needsConfirm: \(proposal.needsConfirm)")

        let outcome = runtime.execute(
            steps: proposal.steps,
            name: proposal.title,
            confirmed: confirm
        )

        switch outcome {
        case .denied:
            print("outcome: denied (pass --confirm to record playbook in stub mode)")
        case .dryRun(let steps):
            print("outcome: dry-run \(steps.count) steps")
        case .confirmedAndRecorded(let playbook):
            await store.save(playbook: playbook)
            print("outcome: recorded playbook '\(playbook.name)' (\(playbook.steps.count) steps)")
        }
    }
}
