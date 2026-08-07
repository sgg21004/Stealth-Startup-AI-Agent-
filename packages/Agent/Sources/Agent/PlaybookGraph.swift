import Foundation

/// Structural step kinds. Irreversible kinds require a confirm predecessor.
public enum GraphNodeKind: String, Sendable, Codable, Equatable {
    case navigate
    case fill
    case confirm
    case spend
    case send
    case delete
    case auth
    case other

    public var isIrreversible: Bool {
        switch self {
        case .spend, .send, .delete, .auth:
            return true
        case .navigate, .fill, .confirm, .other:
            return false
        }
    }
}

public struct GraphNode: Sendable, Equatable, Codable, Identifiable {
    public var id: String
    public var kind: GraphNodeKind
    public var label: String

    public init(id: String = UUID().uuidString, kind: GraphNodeKind, label: String) {
        self.id = id
        self.kind = kind
        self.label = label
    }
}

public struct GraphEdge: Sendable, Equatable, Codable {
    public var from: String
    public var to: String

    public init(from: String, to: String) {
        self.from = from
        self.to = to
    }
}

/// Linear (or edged) playbook graph. Spend/send/delete/auth must follow a confirm node.
public struct PlaybookGraph: Sendable, Equatable, Codable {
    public var nodes: [GraphNode]
    public var edges: [GraphEdge]

    public init(nodes: [GraphNode], edges: [GraphEdge] = []) {
        self.nodes = nodes
        self.edges = edges
    }

    public var irreversibleNodeCount: Int {
        nodes.filter(\.kind.isIrreversible).count
    }

    public var confirmNodeCount: Int {
        nodes.filter { $0.kind == .confirm }.count
    }
}

public enum StepClassifier: Sendable {
    private static let spendSignals = ["pay", "payment", "checkout", "place order", "purchase", "buy"]
    private static let confirmSignals = [
        "confirm", "pause before payment", "ask user", "approval", "pause for user",
    ]
    private static let sendSignals = ["send email", "send message", "sms", "message the"]
    private static let deleteSignals = ["delete", "remove account", "erase"]
    private static let authSignals = ["log in", "login", "sign in", "password", "2fa", "two-factor"]
    private static let fillSignals = ["fill", "enter quantity", "type ", "form field"]
    private static let navigateSignals = ["open ", "navigate", "go to", "click ", "find the"]

    /// One primary kind per step. Confirm wins over spend when both appear (gate-before-money phrasing).
    public static func kind(for step: String) -> GraphNodeKind {
        let s = step.lowercased()
        let hasConfirm = confirmSignals.contains(where: { s.contains($0) })
        let hasSpend = spendSignals.contains(where: { s.contains($0) })
        if hasConfirm { return .confirm }
        if hasSpend { return .spend }
        if sendSignals.contains(where: { s.contains($0) }) { return .send }
        if deleteSignals.contains(where: { s.contains($0) }) { return .delete }
        if looksLikeAuth(s) { return .auth }
        if fillSignals.contains(where: { s.contains($0) }) { return .fill }
        if navigateSignals.contains(where: { s.contains($0) }) { return .navigate }
        return .other
    }

    /// Policy / user-handoff wording is not agent-driven auth.
    private static func looksLikeAuth(_ s: String) -> Bool {
        let negated =
            s.contains("never password")
            || s.contains("no password")
            || s.contains("without password")
            || s.contains("don't use password")
            || s.contains("do not use password")
        if negated { return false }

        // User does auth; agent waits — not an irreversible automation node.
        let userHandoff =
            s.contains("if prompted")
            || s.contains("user logs in")
            || s.contains("user signs in")
            || s.contains("ask user to log")
            || s.contains("wait for login")
            || s.contains("wait for sign in")
        if userHandoff { return false }

        return authSignals.contains(where: { s.contains($0) })
    }
}

public enum PlaybookGraphBuilder: Sendable {
    /// Build a linear graph from free-text steps (untrusted planner output).
    public static func linear(from steps: [String]) -> PlaybookGraph {
        let nodes = steps.map { GraphNode(kind: StepClassifier.kind(for: $0), label: $0) }
        var edges: [GraphEdge] = []
        for i in 0..<(max(0, nodes.count - 1)) {
            edges.append(GraphEdge(from: nodes[i].id, to: nodes[i + 1].id))
        }
        return PlaybookGraph(nodes: nodes, edges: edges)
    }
}

public enum GraphValidationError: Error, Sendable, Equatable, CustomStringConvertible {
    case missingConfirmPredecessor(nodeLabel: String, kind: GraphNodeKind)
    case emptyGraph

    public var description: String {
        switch self {
        case .missingConfirmPredecessor(let label, let kind):
            return "reject: \(kind.rawValue) step lacks confirm predecessor — \"\(label)\""
        case .emptyGraph:
            return "reject: empty playbook graph"
        }
    }
}

public enum PlaybookGraphValidator: Sendable {
    /// Structural rule: every irreversible node must have a confirm node earlier in linear order
    /// (or as an ancestor if edges are non-linear later).
    public static func validate(_ graph: PlaybookGraph) -> Result<PlaybookGraph, GraphValidationError> {
        guard !graph.nodes.isEmpty else { return .failure(.emptyGraph) }

        // Prefer linear order by edge chain when present; else array order.
        let ordered = linearOrder(graph) ?? graph.nodes

        for (idx, node) in ordered.enumerated() {
            guard node.kind.isIrreversible else { continue }
            let predecessors = ordered[..<idx]
            let hasConfirm = predecessors.contains { $0.kind == .confirm }
            if !hasConfirm {
                return .failure(.missingConfirmPredecessor(nodeLabel: node.label, kind: node.kind))
            }
        }
        return .success(graph)
    }

    private static func linearOrder(_ graph: PlaybookGraph) -> [GraphNode]? {
        guard !graph.edges.isEmpty, graph.nodes.count == graph.edges.count + 1 else {
            return nil
        }
        let byId = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, $0) })
        let targets = Set(graph.edges.map(\.to))
        guard let start = graph.nodes.first(where: { !targets.contains($0.id) }) else {
            return nil
        }
        var order: [GraphNode] = [start]
        var current = start.id
        var guardCounter = 0
        while guardCounter < graph.nodes.count {
            guardCounter += 1
            guard let edge = graph.edges.first(where: { $0.from == current }),
                  let next = byId[edge.to] else { break }
            order.append(next)
            current = next.id
        }
        return order.count == graph.nodes.count ? order : nil
    }
}
