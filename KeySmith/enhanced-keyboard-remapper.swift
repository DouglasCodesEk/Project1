import Foundation
import IOKit.hid

class KeyboardRemapper: ObservableObject {
    @Published var devices: [IOHIDDevice] = []
    @Published var contextAwareMappings: [ContextAwareKeyMapping] = []
    private var hidManager: IOHIDManager?
    
    init() {
        setupHIDManager()
    }
    
    private func setupHIDManager() {
        hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        
        guard let manager = hidManager else {
            print("Failed to create HID Manager")
            return
        }
        
        let deviceCriteria = [
            [kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop, kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard],
            [kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop, kIOHIDDeviceUsageKey: kHIDUsage_GD_Keypad]
        ]
        
        IOHIDManagerSetDeviceMatchingMultiple(manager, deviceCriteria as CFArray)
        
        IOHIDManagerRegisterDeviceMatchingCallback(manager, deviceAddedCallback, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterDeviceRemovalCallback(manager, deviceRemovedCallback, Unmanaged.passUnretained(self).toOpaque())
        
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        
        let result = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        if result != kIOReturnSuccess {
            print("Failed to open HID Manager")
        }
    }
    
    func addContextAwareMapping(_ mapping: ContextAwareKeyMapping) {
        contextAwareMappings.append(mapping)
        applyMappings()
    }
    
    func applyMappings() {
        for device in devices {
            applyMappingsToDevice(device)
        }
    }
    
    private func applyMappingsToDevice(_ device: IOHIDDevice) {
        // Implementation depends on the specific device and how it handles remapping
        // This is a placeholder for the actual implementation
        print("Applying mappings to device: \(getDeviceName(device))")
    }
    
    private func getDeviceName(_ device: IOHIDDevice) -> String {
        if let name = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String {
            return name
        }
        return "Unknown Device"
    }
}

// MARK: - HID Callbacks

private func deviceAddedCallback(context: UnsafeMutableRawPointer?, result: IOReturn, sender: UnsafeMutableRawPointer?, device: IOHIDDevice) {
    let remapper = Unmanaged<KeyboardRemapper>.fromOpaque(context!).takeUnretainedValue()
    DispatchQueue.main.async {
        remapper.devices.append(device)
        remapper.applyMappingsToDevice(device)
    }
}

private func deviceRemovedCallback(context: UnsafeMutableRawPointer?, result: IOReturn, sender: UnsafeMutableRawPointer?, device: IOHIDDevice) {
    let remapper = Unmanaged<KeyboardRemapper>.fromOpaque(context!).takeUnretainedValue()
    DispatchQueue.main.async {
        remapper.devices.removeAll { $0 == device }
    }
}
