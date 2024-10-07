import SwiftUI

struct SettingsView: View {
    @AppStorage("hotkeyModifiers") private var hotkeyModifiers = 0
    @AppStorage("hotkeyKeyCode") private var hotkeyKeyCode = 0
    
    let modifiers: [(name: String, value: Int)] = [
        ("None", 0),
        ("Command", 1 << 20),
        ("Option", 1 << 19),
        ("Control", 1 << 18),
        ("Shift", 1 << 17)
    ]
    
    let keyCodes: [(name: String, code: Int)] = [
        ("F1", 122), ("F2", 120), ("F3", 99), ("F4", 118),
        ("F5", 96), ("F6", 97), ("F7", 98), ("F8", 100),
        ("1", 18), ("2", 19), ("3", 20), ("4", 21),
        ("5", 23), ("6", 22), ("7", 26), ("8", 28),
        ("9", 25), ("0", 29)
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Hotkey Settings")) {
                Picker("Modifier", selection: $hotkeyModifiers) {
                    ForEach(modifiers, id: \.value) { modifier in
                        Text(modifier.name).tag(modifier.value)
                    }
                }
                
                Picker("Key", selection: $hotkeyKeyCode) {
                    ForEach(keyCodes, id: \.code) { key in
                        Text(key.name).tag(key.code)
                    }
                }
            }
            
            Section(header: Text("Current Hotkey")) {
                Text(getCurrentHotkeyDescription())
                    .font(.headline)
            }
        }
        .padding()
        .frame(width: 300, height: 200)
        .onChange(of: hotkeyModifiers) { _ in updateHotkey() }
        .onChange(of: hotkeyKeyCode) { _ in updateHotkey() }
    }
    
    private func getCurrentHotkeyDescription() -> String {
        let modifierNames = modifiers.filter { hotkeyModifiers & $0.value != 0 }.map { $0.name }
        let keyName = keyCodes.first { $0.code == hotkeyKeyCode }?.name ?? "Unknown"
        return (modifierNames + [keyName]).joined(separator: " + ")
    }
    
    private func updateHotkey() {
        // Notify AppDelegate to update the hotkey
        NotificationCenter.default.post(name: Notification.Name("UpdateHotkey"), object: nil)
    }
}
