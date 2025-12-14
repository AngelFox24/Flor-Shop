import Foundation
import Security
import FlorShopDTOs

final class TokenStore {
    func query(identifier: TokenRefresableIdentifier) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: Bundle.main.bundleIdentifier ?? "app",
         kSecAttrAccount as String: identifier.identifier]
    }
    func load(identifier: TokenRefresableIdentifier) async throws -> TokenRefreshable? {
        var q = query(identifier: identifier)
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        q[kSecReturnData as String] = kCFBooleanTrue
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return try JSONDecoder().decode(TokenRefreshable.self, from: data)
    }
    func save(_ tokens: TokenRefreshable) async throws {
        let data = try JSONEncoder().encode(tokens)
        var q = query(identifier: tokens.identifier)
        let status = SecItemCopyMatching(q as CFDictionary, nil)
        if status == errSecSuccess {
            let update: [String: Any] = [kSecValueData as String: data]
            _ = SecItemUpdate(q as CFDictionary, update as CFDictionary)
            return
        }
        q[kSecValueData as String] = data
        _ = SecItemAdd(q as CFDictionary, nil)
    }
    func clear(identifier: TokenRefresableIdentifier) async throws {
        let q = query(identifier: identifier)
        _ = SecItemDelete(q as CFDictionary)
    }
}
