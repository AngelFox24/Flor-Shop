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
        print("[TokenStore] Se intenta recuperar un token para: \(identifier.identifier)")
        var q = query(identifier: identifier)
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        q[kSecReturnData as String] = kCFBooleanTrue
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            print("[TokenStore] Se intenta recuperar un token para: \(identifier.identifier), pero no hay ningún token guardado.")
            return nil
        }
        let token = try JSONDecoder().decode(TokenRefreshable.self, from: data)
        print("[TokenStore] Se recupero un token para: \(identifier.identifier), es: \(token.accessToken)")
        return token
    }
    func save(_ tokens: TokenRefreshable) async throws {
        let data = try JSONEncoder().encode(tokens)
        var q = query(identifier: tokens.identifier)
        print("[TokenStore] Se intenta guardar un token para: \(tokens.identifier.identifier)")
        let status = SecItemCopyMatching(q as CFDictionary, nil)
        if status == errSecSuccess {
            let update: [String: Any] = [kSecValueData as String: data]
            _ = SecItemUpdate(q as CFDictionary, update as CFDictionary)
            print("[TokenStore] Se intenta guardar un token para: \(tokens.identifier.identifier), pero ya había uno guardado y se actualizo.")
            return
        }
        q[kSecValueData as String] = data
        _ = SecItemAdd(q as CFDictionary, nil)
        print("[TokenStore] Se guardo un token para: \(tokens.identifier.identifier)")
    }
    func clear(identifier: TokenRefresableIdentifier) async throws {
        let q = query(identifier: identifier)
        _ = SecItemDelete(q as CFDictionary)
        print("[TokenStore] Se elimino un token para: \(identifier.identifier)")
    }
}
