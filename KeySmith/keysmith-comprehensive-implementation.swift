import SwiftUI
import Foundation
import IOKit.hid
import Carbon.HIToolbox
import CoreML
import NaturalLanguage
import CoreLocation
import Network

// MARK: - Main App Structure

@main
struct KeySmithApp: App {
    @StateObject private var macroEngine = MacroEngine()
    @StateObject private var keyboardRemapper = KeyboardRemapper()
    @StateObject private var variableManager = VariableManager()
    @StateObject private var preferencesManager = PreferencesManager()
    @StateObject private var aiAssistant = AIAssistant()
    @StateObject private var contextManager = ContextManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(macroEngine)
                .environmentObject(keyboardRemapper)
                .environmentObject(variableManager)
                .environmentObject(preferencesManager)
                .environmentObject(aiAssistant)
                .environmentObject(contextManager)
        }
        .commands {
            KeySmithCommands(macroEngine: macroEngine, keyboardRemapper: keyboardRemapper)
        }
        
        Settings {
            SettingsView()
                .environmentObject(preferencesManager)
        }
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @State private var selectedTab: Tab = .macros
    @EnvironmentObject var contextManager: ContextManager
    
    enum Tab {
        case macros, keyboardRemapper, visualBuilder, macroTesting
    }
    
    var body: some View {
        NavigationView {
            Sidebar(selectedTab: $selectedTab)
            
            Group {
                switch selectedTab {
                case .macros:
                    MacroEditorView()
                case .keyboardRemapper:
                    KeyboardRemapperView()
                case .visualBuilder:
                    VisualMacroBuilderView()
                case .macroTesting:
                    MacroTestingView()
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .overlay(ContextOverlay(), alignment: .topTrailing)
    }
}

// MARK: - Sidebar

struct Sidebar: View {
    @Binding var selectedTab: ContentView.Tab
    @EnvironmentObject var macroEngine: MacroEngine
    
    var body: some View {
        List {
            Section(header: Text("MACROS")) {
                ForEach(macroEngine.macroGroups) { group in
                    NavigationLink(destination: MacroListView(group: group)) {
                        Label(group.name, systemImage: "folder")
                    }
                }
                Button("Add Group") {
                    macroEngine.addMacroGroup()
                }
            }
            
            Section(header: Text("TOOLS")) {
                NavigationLink(destination: VisualMacroBuilderView()) {
                    Label("Visual Macro Builder", systemImage: "square.grid.2x2")
                }
                .tag(ContentView.Tab.visualBuilder)
                
                NavigationLink(destination: KeyboardRemapperView()) {
                    Label("Keyboard Remapper", systemImage: "keyboard")
                }
                .tag(ContentView.Tab.keyboardRemapper)
                
                NavigationLink(destination: MacroTestingView()) {
                    Label("Macro Testing", systemImage: "hammer")
                }
                .tag(ContentView.Tab.macroTesting)
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
    }
}

// MARK: - Context Manager

class ContextManager: ObservableObject {
    @Published var currentApp: String = ""
    @Published var currentLocation: String = ""
    @Published var timeOfDay: TimeOfDay = .day
    @Published var networkStatus: NetworkStatus = .unknown
    
    private var locationManager: CLLocationManager?
    private var networkMonitor: NWPathMonitor?
    private var timer: Timer?
    
    enum TimeOfDay: String, CaseIterable {
        case morning = "Morning"
        case day = "Day"
        case evening = "Evening"
        case night = "Night"
    }
    
    enum NetworkStatus: String, CaseIterable {
        case wifi = "WiFi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case offline = "Offline"
        case unknown = "Unknown"
    }
    
    init() {
        setupLocationManager()
        setupNetworkMonitor()
        startContextMonitoring()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func setupNetworkMonitor() {
        networkMonitor = NWPathMonitor()
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateNetworkStatus(path)
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor?.start(queue: queue)
    }
    
    private func startContextMonitoring() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeApplicationChanged),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateTimeOfDay()
        }
        
        locationManager?.startUpdatingLocation()
        
        activeApplicationChanged()
        updateTimeOfDay()
    }
    
    @objc private func activeApplicationChanged() {
        if let appName = NSWorkspace.shared.frontmostApplication?.localizedName {
            DispatchQueue.main.async {
                self.currentApp = appName
            }
        }
    }
    
    private func updateTimeOfDay() {
        let hour = Calendar.current.component(.hour, from: Date())
        let newTimeOfDay: TimeOfDay
        
        switch hour {
        case 5..<12: newTimeOfDay = .morning
        case 12..<17: newTimeOfDay = .day
        case 17..<22: newTimeOfDay = .evening
        default: newTimeOfDay = .night
        }
        
        DispatchQueue.main.async {
            self.timeOfDay = newTimeOfDay
        }
    }
    
    private func updateNetworkStatus(_ path: NWPath) {
        let status: NetworkStatus
        if path.usesInterfaceType(.wifi) {
            status = .wifi
        } else if path.usesInterfaceType(.cellular) {
            status = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            status = .ethernet
        } else if path.status == .unsatisfied {
            status = .offline
        } else {
            status = .unknown
        }
        
        DispatchQueue.main.async {
            self.networkStatus = status
        }
    }
}

extension ContextManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    if let locality = placemark.locality {
                        self.currentLocation = locality
                    } else if let name = placemark.name {
                        self.currentLocation = name
                    } else {
                        self.currentLocation = "Unknown Location"
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

// MARK: - Keyboard Remapper

class KeyboardRemapper: ObservableObject {
    @Published var devices: [IOHIDDevice] = []
    @Published var contextAwareMappings: [ContextAwareKeyMapping] = []
    
    func addContextAwareMapping(_ mapping: ContextAwareKeyMapping) {
        contextAwareMappings.append(mapping)
    }
    
    func applyMappings(for context: ContextManager) {
        for mapping in contextAwareMappings {
            if mapping.matchesContext(context) {
                applyKeyMapping(from: mapping.fromKey, to: mapping.toKey)
            }
        }
    }
    
    func applyKeyMapping(from: String, to: String) {
        guard let fromKeyCode = keyCodeForChar(from),
              let toKeyCode = keyCodeForChar(to) else {
            print("Invalid key mapping")
            return
        }
        
        let src = UInt16(fromKeyCode)
        let dst = UInt16(toKeyCode)
        
        var keyMap = [UInt16](repeating: 0, count: 128)
        for i in 0..<128 {
            keyMap[i] = UInt16(i)
        }
        keyMap[src] = dst
        
        let spec = UnsafeMutablePointer<UCKeyboardLayout>.allocate(capacity: 1)
        defer { spec.deallocate() }
        
        let layoutData = UCKeyboardLayout.allocate(capacity: 128)
        defer { layoutData.deallocate() }
        
        for i in 0..<128 {
            layoutData[i] = UInt32(keyMap[i])
        }
        
        spec.pointee = UCKeyboardLayout(keyboardType: 0, keyboardTypeIndex: 0, keyStateRecordsIndexOffset: 0, keyStateRecordsFlat: nil, keyReMapNum: 128, keyRemapData: layoutData)
        
        let status = UCKeyboardLayout.setKeyboardLayout(kUCKeyboardLayoutTypeCustom, spec)
        if status != noErr {
            print("Failed to set keyboard layout: \(status)")
        }
    }
    
    private func keyCodeForChar(_ char: String) -> CGKeyCode? {
        let keyCodeMap: [String: CGKeyCode] = [
            "a": 0x00, "s": 0x01, "d": 0x02, "f": 0x03,
            // Add more mappings here
        ]
        return keyCodeMap[char.lowercased()]
    }
}

struct ContextAwareKeyMapping: Identifiable {
    let id = UUID()
    let fromKey: String
    let toKey: String
    let app: String?
    let location: String?
    let timeOfDay: ContextManager.TimeOfDay?
    let networkStatus: ContextManager.NetworkStatus?
    
    var contextDescription: String {
        var descriptions: [String] = []
        if let app = app { descriptions.append("App: \(app)") }
        if let location = location { descriptions.append("Location: \(location)") }
        if let timeOfDay = timeOfDay { descriptions.append("Time: \(timeOfDay.rawValue)") }
        if let networkStatus = networkStatus { descriptions.append("Network: \(networkStatus.rawValue)") }
        return descriptions.joined(separator: ", ")
    }
    
    func matchesContext(_ context: ContextManager) -> Bool {
        return (app == nil || app == context.currentApp) &&
               (location == nil || location == context.currentLocation) &&
               (timeOfDay == nil || timeOfDay == context.timeOfDay) &&
               (networkStatus == nil || networkStatus == context.networkStatus)
    }
}

// MARK: - Macro Engine

class MacroEngine: ObservableObject {
    @Published var macroGroups: [MacroGroup] = []
    @Published var recentlyUsedMacros: [Macro] = []
    
    func addMacroGroup() {
        let newGroup = MacroGroup(name: "New Group", macros: [])
        macroGroups.append(newGroup)
    }
    
    func addMacro(_ macro: Macro, to group: MacroGroup) {
        if let index = macroGroups.firstIndex(where: { $0.id == group.id }) {
            macroGroups[index].macros.append(macro)
        }
    }
    
    func runMacro(_ macro: Macro, in context: ContextManager) {
        guard macro.shouldRunInContext(context) else {
            print("Macro \(macro.name) skipped due to context mismatch")
            return
        }
        
        for action in macro.actions {
            action.execute(in: context)
        }
        
        updateRecentlyUsedMacros(macro)
    }
    
    private func updateRecentlyUsedMacros(_ macro: Macro) {
        if let index = recentlyUsedMacros.firstIndex(where: { $0.id == macro.id }) {
            recentlyUsedMacros.remove(at: index)
        }
        recentlyUsedMacros.insert(macro, at: 0)
        if recentlyUsedMacros.count > 5 {
            recentlyUsedMacros.removeLast()
        }
    }
}

// MARK: - Macro and Action Models

struct MacroGroup: Identifiable {
    let id = UUID()
    var name: String
    var macros: [Macro]
}

struct Macro: Identifiable {
    let id = UUID()
    var name: String
    var triggers: [MacroTrigger]
    var actions: [Action]
    var contextConditions: MacroContextConditions?
    
    func shouldRunInContext(_ context: ContextManager) -> Bool {
        guard let conditions = contextConditions else { return true }
        return conditions.matches(context)
    }
}

struct MacroContextConditions {
    var apps: [String]?
    var locations: [String]?
    var timeOfDay: [ContextManager.TimeOfDay]?
    var networkStatus: [ContextManager.NetworkStatus]?
    
    func matches(_ context: ContextManager) -> Bool {
        return (apps == nil || apps!.contains(context.currentApp)) &&
               (locations == nil || locations!.contains(context.currentLocation)) &&
               (timeOfDay == nil || timeOfDay!.contains(context.timeOfDay)) &&
               (networkStatus == nil || networkStatus!.contains(context.networkStatus))
    }
}

protocol MacroTrigger {
    // Define properties and methods for triggers
}

protocol Action {
    func execute(in context: ContextManager)
}

struct KeystrokeAction: Action {
    let key: String
    
    func execute(in context: ContextManager) {
        print("Executing keystroke \(key) in context: \(context.currentApp)")
        let source = CGEventSource(stateID: .hidSystemState)
        
        if let keyCode = keyCodeForChar(key) {
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
            let keyUp = CGEvent(