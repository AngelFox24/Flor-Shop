import Foundation

protocol SessionRepository {
    func logIn(username: String, password: String) async throws -> SessionConfig
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig
}

class SessionRepositoryImpl: SessionRepository {
    let remoteManager: RemoteSessionManager
    let cloudBD = true
    init(
        remoteManager: RemoteSessionManager
    ) {
        self.remoteManager = remoteManager
    }
    func logIn(username: String, password: String) async throws -> SessionConfig {
        return try await self.remoteManager.logIn(username: username, password: password)
    }
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig {
        guard let registerParams = RegisterParameters(registerStuff: registerStuff) else {
            throw NetworkError.unknownError(statusCode: 800)
        }
        return try await self.remoteManager.register(registerParams: registerParams)
    }
}
