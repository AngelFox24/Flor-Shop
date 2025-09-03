import Foundation

enum SessionState: Equatable {
    case loggedOut
    case loggedIn(SessionConfig)
}

@Observable
@MainActor
final class SessionManager {
    private let storage: SessionRepository
    private(set) var state: SessionState = .loggedOut
    
    init(storage: SessionRepository) {
        self.storage = storage
        restoreSession()
    }
    
    func login(
        username: String,
        password: String
    ) async throws {
        let session = try await storage.logIn(username: username, password: password)
        self.state = .loggedIn(session)
    }
    
    func logout() {
        storage.clear()
        state = .loggedOut
    }
    
    func register(registerStuff: RegisterStuffs) async throws {
        let session = try await self.storage.register(registerStuff: registerStuff)
        self.state = .loggedIn(session)
    }
    
    private func restoreSession() {
        if let saved = storage.loadSession() {
            self.state = .loggedIn(saved)
        }
    }
}
