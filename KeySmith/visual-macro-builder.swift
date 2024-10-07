import SwiftUI

struct VisualMacroBuilderView: View {
    @State private var actions: [Action] = []
    @State private var draggedAction: Action?
    
    var body: some View {
        HStack {
            actionPalette
            Divider()
            macroBuilder
        }
    }
    
    var actionPalette: some View {
        VStack {
            Text("Action Palette")
                .font(.headline)
            
            ScrollView {
                VStack(spacing: 10) {
                    ActionPaletteItem(action: KeystrokeAction(key: ""), name: "Keystroke")
                    ActionPaletteItem(action: MouseMoveAction(x: 0, y: 0), name: "Mouse Move")
                    ActionPaletteItem(action: MouseClickAction(type: .leftClick), name: "Mouse Click")
                    ActionPaletteItem(action: ClipboardAction(operation: .copy), name: "Clipboard")
                    ActionPaletteItem(action: DelayAction(duration: 1.0), name: "Delay")
                    ActionPaletteItem(action: SystemCommandAction(command: ""), name: "System Command")
                }
            }
        }
        .frame(width: 200)
    }
    
    var macroBuilder: some View {
        VStack {
            Text("Macro Builder")
                .font(.headline)
            
            List {
                ForEach(actions.indices, id: \.self) { index in
                    ActionView(action: actions[index])
                        .onDrag {
                            self.draggedAction = self.actions[index]
                            return NSItemProvider(object: String(index) as NSString)
                        }
                        .onDrop(of: ["public.text"], delegate: DropDelegate(item: actions[index], items: $actions, draggedItem: $draggedAction))
                }
            }
        }
    }
}

struct ActionPaletteItem: View {
    let action: Action
    let name: String
    
    var body: some View {
        Text(name)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .onDrag {
                NSItemProvider(object: name as NSString)
            }
    }
}

struct ActionView: View {
    let action: Action
    
    var body: some View {
        HStack {
            Text(String(describing: type(of: action)))
            Spacer()
            Button("Edit") {
                // TODO: Implement edit functionality
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

struct DropDelegate: DropDelegate {
    let item: Action
    @Binding var items: [Action]
    @Binding var draggedItem: Action?
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem else { return }
        
        if let from = items.firstIndex(where: { $0 === draggedItem }),
           let to = items.firstIndex(where: { $0 === item }) {
            if items[to] !== draggedItem {
                items.move(fromOffsets: IndexSet(integer: from),
                           toOffset: to > from ? to + 1 : to)
            }
        }
    }
}
