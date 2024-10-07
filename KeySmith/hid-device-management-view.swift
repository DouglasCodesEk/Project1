import SwiftUI

struct HIDDeviceManagementView: View {
    @EnvironmentObject var keyboardRemapper: KeyboardRemapper
    @EnvironmentObject var contextManager: ContextManager
    @State private var selectedDevice: IOHIDDevice?
    @State private var newMapping = ContextAwareKeyMapping(fromKey: "", toKey: "", app: nil, location: nil, timeOfDay: nil, networkStatus: nil)
    
    var body: some View {
        HSplitView {
            deviceList
            
            VStack {
                deviceDetails
                mappingsList
                newMappingForm
            }
        }
        .navigationTitle("HID Device Management")
    }
    
    var deviceList: some View {
        List(keyboardRemapper.devices, id: \.self, selection: $selectedDevice) { device in
            Text(keyboardRemapper.getDeviceName(device))
        }
        .frame(minWidth: 200)
    }
    
    @ViewBuilder
    var deviceDetails: some View {
        if let device = selectedDevice {
            VStack(alignment: .leading) {
                Text("Device Details")
                    .font(.headline)
                Text("Name: \(keyboardRemapper.getDeviceName(device))")
                Text("Vendor ID: \(IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int ?? 0)")
                Text("Product ID: \(IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int ?? 0)")
            }
            .padding()
        } else {
            Text("Select a device to view details")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var mappingsList: some View {
        List {
            ForEach(keyboardRemapper.contextAwareMappings) { mapping in
                HStack {
                    Text("\(mapping.fromKey) → \(mapping.toKey)")
                    Spacer()
                    Text(mapping.contextDescription)
                        .font(.caption)
                }
            }
            .onDelete(perform: deleteMappings)
        }
    }
    
    var newMappingForm: some View {
        Form {
            TextField("From Key", text: $newMapping.fromKey)
            TextField("To Key", text: $newMapping.toKey)
            Picker("App", selection: $newMapping.app) {
                Text("Any").tag(nil as String?)
                ForEach(getRecentApps(), id: \.self) { app in
                    Text(app).tag(app as String?)
                }
            }
            Picker("Location", selection: $newMapping.location) {
                Text("Any").tag(nil as String?)
                ForEach(getRecentLocations(), id: \.self) { location in
                    Text(location).tag(location as String?)
                }
            }
            Picker("Time of Day", selection: $newMapping.timeOfDay) {
                Text("Any").tag(nil as ContextManager.TimeOfDay?)
                ForEach(ContextManager.TimeOfDay.allCases, id: \.self) { time in
                    Text(time.rawValue).tag(time as ContextManager.TimeOfDay?)
                }
            }
            Picker("Network Status", selection: $newMapping.networkStatus) {
                Text("Any").tag(nil as ContextManager.NetworkStatus?)
                ForEach(ContextManager.NetworkStatus.allCases, id: \.self) { status in
                    Text(status.rawValue).tag(status as ContextManager.NetworkStatus?)
                }
            }
            
            Button("Add Mapping") {
                keyboardRemapper.addContextAwareMapping(newMapping)
                newMapping = ContextAwareKeyMapping(fromKey: "", toKey: "", app: nil, location: nil, timeOfDay: nil, networkStatus: nil)
            }
        }
    }
    
    private func deleteMappings(at offsets: IndexSet) {
        keyboardRemapper.contextAwareMappings.remove(atOffsets: offsets)
        keyboardRemapper.applyMappings()
    }
    
    private func getRecentApps() -> [String] {
        // This should be implemented to return a list of recently used apps
        return ["Safari", "Mail", "Xcode", "Terminal"]
    }
    
    private func getRecentLocations() -> [String] {
        // This should be implemented to return a list of recent locations
        return ["Home", "Office", "Coffee Shop"]
    }
}
