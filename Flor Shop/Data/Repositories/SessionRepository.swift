import Foundation

protocol SessionRepository {
    func loadSession() -> SessionConfig?
    func logIn(username: String, password: String) async throws -> SessionConfig
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig
    func clear()
}

class SessionRepositoryImpl: SessionRepository {
    let remoteManager: RemoteSessionManager
    let localManager: LocalSessionManager
    let cloudBD = true
    init(
        remoteManager: RemoteSessionManager,
        localManager: LocalSessionManager
    ) {
        self.remoteManager = remoteManager
        self.localManager = localManager
    }
    func loadSession() -> SessionConfig? {
        return self.localManager.loadSession()
    }
    func logIn(username: String, password: String) async throws -> SessionConfig {
        let session = try await self.remoteManager.logIn(username: username, password: password)
        self.saveSession(session)
        return session
    }
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig {
        guard let registerParams = RegisterParameters(registerStuff: registerStuff) else {
            throw NetworkError.unknownError(statusCode: 800)
        }
        let session = try await self.remoteManager.register(registerParams: registerParams)
        self.saveSession(session)
        return session
    }
    func clear() {
         self.localManager.clear()
    }
    private func saveSession(_ sessionConfig: SessionConfig) {
        self.localManager.saveSession(sessionConfig)
    }
}
