import SwiftUI

extension VisualMacroBuilderView {
    func handleConnectionStart(from node: MacroNode, position: CGPoint) {
        connectionStart = position
        isAddingConnection = true
    }
    
    func handleConnectionEnd(to node: MacroNode) {
        guard let start = connectionStart, let draggedNode = draggedNode else {
            isAddingConnection = false
            connectionStart = nil
            connectionEnd = nil
            return
        }
        
        let newConnection = NodeConnection(fromNode: draggedNode.id, toNode: node.id)
        connections.append(newConnection)
        
        isAddingConnection = false
        connectionStart = nil
        connectionEnd = nil
    }
}

struct NodeConnector: View {
    enum Role {
        case input, output
    }
    
    let role: Role
    let node: MacroNode
    let onStartConnection: (MacroNode, CGPoint) -> Void
    let onEndConnection: (MacroNode) -> Void
    
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 10, height: 10)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if role == .output {
                            onStartConnection(node, value.location)
                        }
                    }
                    .onEnded { _ in
                        if role == .input {
                            onEndConnection(node)
                        }
                    }
            )
    }
}
