import Foundation
import AppKit

struct MouseMoveAction: Action {
    let x: Int
    let y: Int
    
    func execute(in context: MacroExecutionContext) async throws {
        let screenFrame = NSScreen.main?.frame ?? .zero
        let point = CGPoint(x: x, y: Int(screenFrame.height) - y)  // Invert Y-coordinate
        CGWarpMouseCursorPosition(point)
    }
}

struct MouseClickAction: Action {
    enum ClickType {
        case leftClick
        case rightClick
        case doubleClick
    }
    
    let type: ClickType
    
    func execute(in context: MacroExecutionContext) async throws {
        let currentPosition = NSEvent.mouseLocation
        let event: CGEvent?
        
        switch type {
        case .leftClick:
            event = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: currentPosition, mouseButton: .left)
            event?.post(tap: .cghidEventTap)
            event = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: currentPosition, mouseButton: .left)
        case .rightClick:
            event = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: currentPosition, mouseButton: .right)
            event?.post(tap: .cghidEventTap)
            event = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: currentPosition, mouseButton: .right)
        case .doubleClick:
            event = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: currentPosition, mouseButton: .left)
            event?.post(tap: .cghidEventTap)
            event = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: currentPosition, mouseButton: .left)
            event?.post(tap: .cghidEventTap)
            event = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: currentPosition, mouseButton: .left)
            event?.post(tap: .cghidEventTap)
            event = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: currentPosition, mouseButton: .left)
        }
        
        event?.post(tap: .cghidEventTap)
    }
}

struct ClipboardAction: Action {
    enum Operation {
        case copy
        case paste
        case cut
        case setContent(String)
    }
    
    let operation: Operation
    
    func execute(in context: MacroExecutionContext) async throws {
        let pasteboard = NSPasteboard.general
        
        switch operation {
        case .copy:
            let source = CGEventSource(stateID: .hidSystemState)
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
            keyDown?.flags = .maskCommand
            keyUp?.flags = .maskCommand
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        case .paste:
            let source = CGEventSource(stateID: .hidSystemState)
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
            keyDown?.flags = .maskCommand
            keyUp?.flags = .maskCommand
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        case .cut:
            let source = CGEventSource(stateID: .hidSystemState)
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x07, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x07, keyDown: false)
            keyDown?.flags = .maskCommand
            keyUp?.flags = .maskCommand
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        case .setContent(let content):
            pasteboard.clearContents()
            pasteboard.setString(content, forType: .string)
        }
    }
}

struct SystemCommandAction: Action {
    let command: String
    
    func execute(in context: MacroExecutionContext) async throws {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        try task.run()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            context.variables["lastCommandOutput"] = output
        }
    }
}
