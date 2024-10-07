import SwiftUI

struct NodeConfigurationView: View {
    @Binding var node: MacroNode
    
    var body: some View {
        Form {
            Section(header: Text("Node Configuration")) {
                TextField("Name", text: Binding(
                    get: { node.properties["name"] as? String ?? "" },
                    set: { node.properties["name"] = $0 }
                ))
                
                switch node.type {
                case .trigger:
                    triggerConfiguration
                case .action:
                    actionConfiguration
                case .condition:
                    conditionConfiguration
                case .loop:
                    loopConfiguration
                }
            }
        }
    }
    
    var triggerConfiguration: some View {
        Group {
            Picker("Trigger Type", selection: Binding(
                get: { node.properties["triggerType"] as? TriggerType ?? .hotkey },
                set: { node.properties["triggerType"] = $0 }
            )) {
                ForEach(TriggerType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            if node.properties["triggerType"] as? TriggerType == .hotkey {
                TextField("Hotkey", text: Binding(
                    get: { node.properties["hotkey"] as? String ?? "" },
                    set: { node.properties["hotkey"] = $0 }
                ))
            }
        }
    }
    
    var actionConfiguration: some View {
        Group {
            Picker("Action Type", selection: Binding(
                get: { node.properties["actionType"] as? ActionType ?? .keystroke },
                set: { node.properties["actionType"] = $0 }
            )) {
                ForEach(ActionType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            switch node.properties["actionType"] as? ActionType {
            case .keystroke:
                TextField("Key", text: Binding(
                    get: { node.properties["key"] as? String ?? "" },
                    set: { node.properties["key"] = $0 }
                ))
            case .mouseClick:
                Picker("Click Type", selection: Binding(
                    get: { node.properties["clickType"] as? ClickType ?? .left },
                    set: { node.properties["clickType"] = $0 }
                )) {
                    ForEach(ClickType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            case .delay:
                TextField("Delay (seconds)", value: Binding(
                    get: { node.properties["delay"] as? Double ?? 0 },
                    set: { node.properties["delay"] = $0 }
                ), formatter: NumberFormatter())
            default:
                EmptyView()
            }
        }
    }
    
    var conditionConfiguration: some View {
        Group {
            TextField("Condition", text: Binding(
                get: { node.properties["condition"] as? String ?? "" },
                set: { node.properties["condition"] = $0 }
            ))
        }
    }
    
    var loopConfiguration: some View {
        Group {
            Stepper("Repeat Count: \(node.properties["repeatCount"] as? Int ?? 1)", value: Binding(
                get: { node.properties["repeatCount"] as? Int ?? 1 },
                set: { node.properties["repeatCount"] = $0 }
            ), in: 1...100)
        }
    }
}

enum TriggerType: String, CaseIterable {
    case hotkey = "Hotkey"
    case appLaunch = "App Launch"
    case timeOfDay = "Time of Day"
}

enum ActionType: String, CaseIterable {
    case keystroke = "Keystroke"
    case mouseClick = "Mouse Click"
    case delay = "Delay"
    case runScript = "Run Script"
}

enum ClickType: String, CaseIterable {
    case left = "Left Click"
    case right = "Right Click"
    case double = "Double Click"
}
