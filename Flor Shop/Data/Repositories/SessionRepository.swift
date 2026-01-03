import Foundation
import FlorShopDTOs

protocol SessionRepository {
    func loadSession() -> SessionConfig?
    func logIn(provider: AuthProvider, token: String) async throws -> [CompanyResponseDTO]
    func getSubsidiaries(companyCic: String) async throws -> [SubsidiaryResponseDTO]
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig
    func selectSubsidiary(subsidiaryCic: String) async throws -> SessionConfig
    func completeProfile(employee: Employee, subsidiaryCic: String, subdomain: String) async throws
    func isRegistrationComplete(subsidiaryCic: String, subdomain: String) async throws -> Bool
    func clear()
}

final class SessionRepositoryImpl: SessionRepository {
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
    func logIn(provider: AuthProvider, token: String) async throws -> [CompanyResponseDTO] {
        try await self.remoteManager.login(provider: provider, token: token)
        return try await self.remoteManager.getCompanies()
    }
    func getSubsidiaries(companyCic: String) async throws -> [SubsidiaryResponseDTO] {
        return try await self.remoteManager.getSubsidiaries(companyCic: companyCic)
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
    func completeProfile(employee: Employee, subsidiaryCic: String, subdomain: String) async throws {
        try await self.remoteManager.completeProfile(employee: employee, subsidiaryCic: subsidiaryCic, subdomain: subdomain)
    }
    func isRegistrationComplete(subsidiaryCic: String, subdomain: String) async throws -> Bool {
        return try await self.remoteManager.isRegistrationComplete(subsidiaryCic: subsidiaryCic, subdomain: subdomain)
    }
    func clear() {
         self.localManager.clear()
    }
    private func saveSession(_ sessionConfig: SessionConfig) {
        self.localManager.saveSession(sessionConfig)
    }
}

extension SessionRepositoryImpl {
    static func mock() -> SessionRepositoryImpl {
        return SessionRepositoryImpl(
            remoteManager: RemoteSessionManagerMock(),
            localManager: LocalSessionManagerMock()
        )
    }
}
