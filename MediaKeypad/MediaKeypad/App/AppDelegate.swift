import Cocoa
import HotKey
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var hotKey: HotKey?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "SynonymFetcher")
        }
        
        setupMenu()
        
        // Set up the hot key (Keypad 7)
        hotKey = HotKey(key: .keypad7, modifiers: [])
        hotKey?.keyDownHandler = {
            self.fetchAndPasteSynonyms()
        }
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Fetch Synonyms", action: #selector(fetchAndPasteSynonyms), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func fetchAndPasteSynonyms() {
        // Get the current clipboard content
        guard let word = NSPasteboard.general.string(forType: .string) else {
            print("No text in clipboard")
            return
        }
        
        // Call the Python script to fetch synonyms
        let synonyms = runPythonScript(word: word)
        
        // Set the clipboard to the synonyms
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(synonyms, forType: .string)
        
        // Simulate CMD+V to paste the synonyms
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
    
    func runPythonScript(word: String) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["python3", "/path/to/your/synonym_fetcher.py", word]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        return "Error fetching synonyms"
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateHotkey), name: Notification.Name("UpdateHotkey"), object: nil)
    }

    @objc func updateHotkey() {
        let modifiers = NSEvent.ModifierFlags(rawValue: UInt(UserDefaults.standard.integer(forKey: "hotkeyModifiers")))
        let keyCode = UserDefaults.standard.integer(forKey: "hotkeyKeyCode")
        
        hotKey = HotKey(keyCombo: KeyCombo(key: Key(carbonKeyCode: UInt32(keyCode)), modifiers: modifiers))
        hotKey?.keyDownHandler = { [weak self] in
            self?.performKeypadAction()
        }
    
    }
    
    @objc func openSettings() {
        let settingsView = SettingsView()
        let controller = NSHostingController(rootView: settingsView)
        let window = NSWindow(contentViewController: controller)
        window.title = "MediaKeypad Settings"
        window.makeKeyAndOrderFront(nil)
    }
}
