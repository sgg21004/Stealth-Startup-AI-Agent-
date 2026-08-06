import XCTest
import Sensor
import Context
import Agent
import Behavior

final class AgentTests: XCTestCase {
    func testBrowserContextYieldsReorderProposal() throws {
        let snapshot = CursorSnapshot(x: 10, y: 20, frontmostApp: "Safari")
        let pack = ContextAssembler().assemble(from: snapshot)
        let prefs = [Preference(key: "preferred_vendor", value: "Test Vendor")]
        let proposal = try AgentBrain().propose(from: pack, preferences: prefs).get()
        XCTAssertTrue(proposal.title.contains("Test Vendor"))
        XCTAssertEqual(proposal.needsConfirm, true)
        XCTAssertEqual(proposal.risk, .spend)
    }

    func testNonBrowserYieldsNoProposal() {
        let snapshot = CursorSnapshot(x: 0, y: 0, frontmostApp: "Notes")
        let pack = ContextAssembler().assemble(from: snapshot)
        let result = AgentBrain().propose(from: pack, preferences: [])
        XCTAssertEqual(result, .failure(.emptyPlan))
    }

    func testRejectsCredentialMemoryPlan() {
        let bad = ProposedAction(
            title: "Reorder",
            steps: ["Save login credentials", "Place order"],
            risk: .spend
        )
        XCTAssertEqual(PlanValidator.validate(bad), .failure(.credentialMemoryRequested))
    }

    func testMemoryPolicyBlocksPasswordKey() {
        let pref = Preference(key: "amazon_password", value: "x")
        XCTAssertEqual(MemoryPolicy.validate(preference: pref), .failure(.neverStoreKey("amazon_password")))
    }
}
