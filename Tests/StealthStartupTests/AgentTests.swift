import XCTest
import Sensor
import Context
import Agent
import Behavior

final class AgentTests: XCTestCase {
    func testBrowserContextYieldsReorderProposal() {
        let snapshot = CursorSnapshot(x: 10, y: 20, frontmostApp: "Safari")
        let pack = ContextAssembler().assemble(from: snapshot)
        let prefs = [Preference(key: "preferred_vendor", value: "Test Vendor")]
        let proposal = AgentBrain().propose(from: pack, preferences: prefs)
        XCTAssertEqual(proposal?.title.contains("Test Vendor"), true)
        XCTAssertEqual(proposal?.needsConfirm, true)
    }

    func testNonBrowserYieldsNoProposal() {
        let snapshot = CursorSnapshot(x: 0, y: 0, frontmostApp: "Notes")
        let pack = ContextAssembler().assemble(from: snapshot)
        let proposal = AgentBrain().propose(from: pack, preferences: [])
        XCTAssertNil(proposal)
    }
}
