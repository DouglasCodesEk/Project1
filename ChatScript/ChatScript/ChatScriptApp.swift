import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var settingsWindow: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarItem()
        setupPopover()
        setupMenus()
        setupSettingsWindow()
    }

    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "text.and.command.macwindow", accessibilityDescription: "ChatScripts")
            button.action = #selector(togglePopover(_:))
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 700)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }

    @objc func togglePopover(_ sender: Any?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    private func setupMenus() {
        guard let mainMenu = NSApp.mainMenu else {
            return
        }

        // Create "ChatScript" menu
        let chatScriptMenu = NSMenu(title: "ChatScript")
        let chatScriptMenuItem = NSMenuItem(title: "ChatScript", action: nil, keyEquivalent: "")
        chatScriptMenuItem.submenu = chatScriptMenu
        mainMenu.insertItem(chatScriptMenuItem, at: 1)

        let aboutMenuItem = NSMenuItem(title: "About ChatScript", action: #selector(showAbout), keyEquivalent: "")
        aboutMenuItem.target = self
        chatScriptMenu.addItem(aboutMenuItem)

        let settingsMenuItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        settingsMenuItem.target = self
        chatScriptMenu.addItem(settingsMenuItem)

        // Create "Help" menu
        let helpMenu = NSMenu(title: "Help")
        let helpMenuItem = NSMenuItem(title: "Help", action: nil, keyEquivalent: "")
        helpMenuItem.submenu = helpMenu
        mainMenu.addItem(helpMenuItem)

        let chatScriptHelpMenu = NSMenu(title: "ChatScript Help")
        let chatScriptHelpMenuItem = NSMenuItem(title: "ChatScript Help", action: nil, keyEquivalent: "")
        chatScriptHelpMenuItem.submenu = chatScriptHelpMenu
        helpMenu.addItem(chatScriptHelpMenuItem)

        let userGuideMenuItem = NSMenuItem(title: "User Guide", action: #selector(openUserGuide), keyEquivalent: "")
        userGuideMenuItem.target = self
        let readmeMenuItem = NSMenuItem(title: "README", action: #selector(openReadme), keyEquivalent: "")
        readmeMenuItem.target = self
        chatScriptHelpMenu.addItem(userGuideMenuItem)
        chatScriptHelpMenu.addItem(readmeMenuItem)
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "About ChatScript"
        alert.informativeText = """
        ChatScript v1.0

        An AI-powered AppleScript generator and executor.

        © 2024 Your Company Name. All rights reserved.
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc func openUserGuide() {
        openDocument(named: "UserGuide")
    }

    @objc func openReadme() {
        openDocument(named: "README")
    }

    private func openDocument(named documentName: String) {
        guard let documentPath = Bundle.main.path(forResource: documentName, ofType: "md") else {
            print("\(documentName) not found")
            return
        }
        
        let url = URL(fileURLWithPath: documentPath)
        NSWorkspace.shared.open(url)
    }

    @objc func openSettings() {
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func setupSettingsWindow() {
        let settingsView = SettingsView()
        settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        settingsWindow.title = "Settings"
        settingsWindow.contentView = NSHostingView(rootView: settingsView)
    }
}

@main
struct ChatScriptApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}   
