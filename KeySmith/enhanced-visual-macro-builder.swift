import SwiftUI

struct VisualMacroBuilderView: View {
    @State private var nodes: [MacroNode] = []
    @State private var connections: [NodeConnection] = []
    @State private var draggedNode: MacroNode?
    @State private var isAddingConnection: Bool = false
    @State private var connectionStart: CGPoint?
    @State private var connectionEnd: CGPoint?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Canvas { context, size in
                    for connection in connections {
                        let start = nodes.first { $0.id == connection.fromNode }?.position ?? .zero
                        let end = nodes.first { $0.id == connection.toNode }?.position ?? .zero
                        context.stroke(
                            Path { path in
                                path.move(to: start)
                                path.addLine(to: end)
                            },
                            with: .color(.blue),
                            lineWidth: 2
                        )
                    }
                    
                    if isAddingConnection, let start = connectionStart, let end = connectionEnd {
                        context.stroke(
                            Path { path in
                                path.move(to: start)
                                path.addLine(to: end)
                            },
                            with: .color(.green),
                            lineWidth: 2
                        )
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if isAddingConnection {
                                connectionEnd = value.location
                            }
                        }
                        .onEnded { _ in
                            isAddingConnection = false
                            connectionStart = nil
                            connectionEnd = nil
                        }
                )
                
                ForEach(nodes) { node in
                    MacroNodeView(node: node, isSelected: draggedNode?.id == node.id)
                        .position(node.position)
                        .gesture(nodeDragGesture(for: node))
                }
                
                VStack {
                    Spacer()
                    HStack {
                        ForEach(MacroNodeType.allCases, id: \.self) { nodeType in
                            Button(action: {
                                addNode(type: nodeType, at: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                            }) {
                                Text(nodeType.rawValue)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Visual Macro Builder")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save Macro") {
                    saveMacro()
                }
            }
        }
    }
    
    private func nodeDragGesture(for node: MacroNode) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if let index = nodes.firstIndex(where: { $0.id == node.id }) {
                    nodes[index].position = value.location
                }
                draggedNode = node
            }
            .onEnded { _ in
                draggedNode = nil
            }
    }
    
    private func addNode(type: MacroNodeType, at position: CGPoint) {
        let newNode = MacroNode(type: type, position: position)
        nodes.append(newNode)
    }
    
    private func saveMacro() {
        // TODO: Implement macro saving logic
        print("Saving macro...")
    }
}

struct MacroNode: Identifiable {
    let id = UUID()
    var type: MacroNodeType
    var position: CGPoint
    var properties: [String: Any] = [:]
}

enum MacroNodeType: String, CaseIterable {
    case trigger = "Trigger"
    case action = "Action"
    case condition = "Condition"
    case loop = "Loop"
}

struct NodeConnection: Identifiable {
    let id = UUID()
    let fromNode: UUID
    let toNode: UUID
}

struct MacroNodeView: View {
    let node: MacroNode
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Text(node.type.rawValue)
                .padding()
                .background(isSelected ? Color.yellow : Color.gray)
                .foregroundColor(.black)
                .cornerRadius(8)
            
            HStack {
                NodeConnector(role: .input)
                Spacer()
                NodeConnector(role: .output)
            }
        }
        .frame(width: 100, height: 60)
    }
}

struct NodeConnector: View {
    enum Role {
        case input, output
    }
    
    let role: Role
    
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 10, height: 10)
    }
}
