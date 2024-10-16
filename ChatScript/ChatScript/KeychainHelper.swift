import Foundation
import Security

enum APIProvider: String {
    case openAI
    case anthropic
}

class KeychainHelper {
    static func saveAPIKey(_ key: String, for provider: APIProvider) {
        guard let data = key.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: provider.rawValue,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving API key for \(provider): \(status)")
        }
    }

    static func getAPIKey(for provider: APIProvider) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: provider.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data, let key = String(data: data, encoding: .utf8) {
            return key
        }

        return nil
    }
}
