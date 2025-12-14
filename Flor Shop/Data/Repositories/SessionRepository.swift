import Foundation
import FlorShopDTOs

protocol SessionRepository {
    func loadSession() -> SessionConfig?
    func logIn(provider: AuthProvider, token: String) async throws
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig
    func selectSubsidiary(subsidiaryCic: String) async throws -> SessionConfig
    func clear()
}

class SessionRepositoryImpl: SessionRepository {
    let remoteManager: RemoteSessionManager
    let localManager: LocalSessionManager
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
    func logIn(provider: AuthProvider, token: String) async throws {
        try await self.remoteManager.login(provider: provider, token: token)
    }
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig {
        let session = try await self.remoteManager.register(registerStuff: registerStuff)
        self.saveSession(session)
        return session
    }
    func selectSubsidiary(subsidiaryCic: String) async throws -> SessionConfig {
        let session = try await self.remoteManager.selectSubsidiary(subsidiaryCic: subsidiaryCic)
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
