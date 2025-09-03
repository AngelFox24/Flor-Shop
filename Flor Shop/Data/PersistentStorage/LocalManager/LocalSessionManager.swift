import Foundation

protocol LocalSessionManager {
    func loadSession() -> SessionConfig?
    func saveSession(_ session: SessionConfig)
    func clear()
}

final class LocalSessionManagerImpl: LocalSessionManager {
    private let defaults = UserDefaults.standard
    
    func loadSession() -> SessionConfig? {
        guard let data = defaults.data(forKey: "session") else { return nil }
        return try? JSONDecoder().decode(SessionConfig.self, from: data)
    }
    
    func saveSession(_ session: SessionConfig) {
        if let data = try? JSONEncoder().encode(session) {
            defaults.set(data, forKey: "session")
        }
        // Ejemplo: podrías guardar token en Keychain aquí
    }
    
    func clear() {
        defaults.removeObject(forKey: "session")
    }
}
