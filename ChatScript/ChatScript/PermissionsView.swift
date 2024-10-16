import SwiftUI

struct PermissionsView: View {
    @Binding var selectedPermissions: ScriptPermission

    var body: some View {
        List {
            ForEach(ScriptPermissionType.allCases) { permissionType in
                Toggle(isOn: Binding(
                    get: { selectedPermissions.contains(ScriptPermission(permissionType: permissionType)) },
                    set: { isOn in
                        if isOn {
                            selectedPermissions.insert(ScriptPermission(permissionType: permissionType))
                        } else {
                            selectedPermissions.remove(ScriptPermission(permissionType: permissionType))
                        }
                    }
                )) {
                    Text(permissionType.rawValue)
                }
            }
        }
    }
}
