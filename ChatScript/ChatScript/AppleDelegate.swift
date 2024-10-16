// AppDelegate.swift

import SwiftUI
import AppKit
import SwiftData

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var mainWindow: NSWindow!
    var settingsWindow: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarItem()
        setupMainWindow()
        setupMenus()
        setupSettingsWindow()
        Logger.shared.info("Application did finish launching")
    }

    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "text.and.command.macwindow",
                                   accessibilityDescription: "ChatScripts")
            button.action = #selector(openMainWindow)
        }
    }

    @objc func openMainWindow() {
        mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func setupMainWindow() {
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 800),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        mainWindow.title = "ChatScripts"
        mainWindow.contentView = NSHostingView(
            rootView: ContentView()
                .environment(\.modelContext, PersistenceController.shared.container.mainContext)
        )
    }

    private func setupMenus() {
        guard let mainMenu = NSApp.mainMenu else {
            return
        }

        // Setup Help Menu
        if let helpMenuItem = mainMenu.item(withTitle: "Help"), let helpMenu = helpMenuItem.submenu {
            helpMenu.addItem(NSMenuItem.separator())

            let userGuideMenuItem = NSMenuItem(title: "User Guide", action: #selector(openUserGuide), keyEquivalent: "")
            userGuideMenuItem.target = self
            helpMenu.addItem(userGuideMenuItem)

            let readmeMenuItem = NSMenuItem(title: "README", action: #selector(openReadme), keyEquivalent: "")
            readmeMenuItem.target = self
            helpMenu.addItem(readmeMenuItem)

            let welcomeGuideMenuItem = NSMenuItem(title: "Welcome Guide", action: #selector(showWelcomeGuide), keyEquivalent: "")
            welcomeGuideMenuItem.target = self
            helpMenu.addItem(welcomeGuideMenuItem)

            let openLogsItem = NSMenuItem(title: "Open Logs Folder", action: #selector(openLogsFolder), keyEquivalent: "")
            openLogsItem.target = self
            helpMenu.addItem(openLogsItem)
        }

        // Setup Application Menu
        if let appMenuItem = mainMenu.items.first, let appMenu = appMenuItem.submenu {
            if appMenu.item(withTitle: "Settings...") == nil {
                let settingsMenuItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
                settingsMenuItem.target = self
                appMenu.insertItem(settingsMenuItem, at: 1)
            }
        }

        // Setup Window Menu
        if let windowMenuItem = mainMenu.item(withTitle: "Window"), let windowMenu = windowMenuItem.submenu {
            windowMenu.addItem(NSMenuItem.separator())

            // Script Library
            let scriptLibraryMenuItem = NSMenuItem(title: "Script Library", action: #selector(openScriptLibrary), keyEquivalent: "L")
            scriptLibraryMenuItem.target = self
            scriptLibraryMenuItem.keyEquivalentModifierMask = [.command, .shift]
            windowMenu.addItem(scriptLibraryMenuItem)

            // Variables
            let variablesMenuItem = NSMenuItem(title: "Variables", action: #selector(openVariablesWindow), keyEquivalent: "V")
            variablesMenuItem.target = self
            variablesMenuItem.keyEquivalentModifierMask = [.command, .shift]
            windowMenu.addItem(variablesMenuItem)

            // Preset Scripts
            let presetScriptsMenuItem = NSMenuItem(title: "Preset Scripts", action: #selector(openPresetScripts), keyEquivalent: "P")
            presetScriptsMenuItem.target = self
            presetScriptsMenuItem.keyEquivalentModifierMask = [.command, .shift]
            windowMenu.addItem(presetScriptsMenuItem)
        }
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "About ChatScripts"
        alert.informativeText = """
        ChatScripts v1.0

        An AI-powered AppleScript generator and executor.

        © 2024 Your Company Name. All rights reserved.
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc func openUserGuide() {
        openDocument(named: "UserGuide", fileExtension: "pdf")
    }

    @objc func openReadme() {
        openDocument(named: "README", fileExtension: "pdf")
    }

    private func openDocument(named documentName: String, fileExtension: String) {
        guard let documentURL = Bundle.main.url(forResource: documentName, withExtension: fileExtension) else {
            Logger.shared.error("\(documentName).\(fileExtension) not found")
            return
        }

        NSWorkspace.shared.open(documentURL)
    }

    @objc func showWelcomeGuide() {
        let welcomeView = WelcomeView(showWelcomeScreen: .constant(true))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentView = NSHostingView(rootView: welcomeView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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

    @objc func openLogsFolder() {
        NSWorkspace.shared.selectFile(Logger.shared.logFileURL.path, inFileViewerRootedAtPath: "")
    }

    @MainActor
    @objc func openScriptLibrary() {
        let scriptLibraryView = ScriptLibraryView(context: PersistenceController.shared.container.mainContext)
            .environment(\.modelContext, PersistenceController.shared.container.mainContext)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Script Library"
        window.contentView = NSHostingView(rootView: scriptLibraryView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @MainActor
    @objc func openVariablesWindow() {
        let variablesView = VariablesView(context: PersistenceController.shared.container.mainContext)
            .environment(\.modelContext, PersistenceController.shared.container.mainContext)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Variables"
        window.contentView = NSHostingView(rootView: variablesView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @MainActor
    @objc func openPresetScripts() {
        let presetScriptsView = PresetScriptsView()
            .environment(\.modelContext, PersistenceController.shared.container.mainContext)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Preset Scripts"
        window.contentView = NSHostingView(rootView: presetScriptsView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
