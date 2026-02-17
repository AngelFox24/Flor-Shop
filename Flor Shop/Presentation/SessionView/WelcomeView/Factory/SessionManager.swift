import Foundation
import FlorShopDTOs

enum SessionState: Equatable {
    case loggedOut
//    case preLogIn(companies: [CompanyResponseDTO])
    case loggedIn(SessionConfig)
}

@Observable
@MainActor
final class SessionManager {
    private let sessionRepository: SessionRepository
    private(set) var state: SessionState = .loggedOut
    
    init(sessionRepository: SessionRepository) {
        self.sessionRepository = sessionRepository
    }
    
    func login(
        provider: AuthProvider,
        token: String
    ) async throws -> [CompanyResponseDTO] {
        let companies = try await sessionRepository.logIn(provider: provider, token: token)
//        self.state = .preLogIn(companies: companies)
        return companies
    }
    
    func getSubsidiaries(companyCic: String) async throws -> [SubsidiaryResponseDTO] {
        return try await self.sessionRepository.getSubsidiaries(companyCic: companyCic)
    }
    
    func logout() {
        sessionRepository.clear()
        print("[SessionManager] Logged out, logout")
        state = .loggedOut
    }
    @discardableResult
    func selectSubsidiary(subsidiaryCic: String) async throws -> SessionConfig {
        let session: SessionConfig = try await self.sessionRepository.selectSubsidiary(subsidiaryCic: subsidiaryCic)
        let isRegistered = try await self.isRegistrationComplete(subsidiaryCic: session.subsidiaryCic)
        if isRegistered {
            print("[SessionManager] Logged in, selectSubsidiary")
            self.state = .loggedIn(session)
        }
        return session
    }
    
    func completeProfile(employee: Employee, subsidiaryCic: String) async throws {
        try await self.sessionRepository.completeProfile(employee: employee, subsidiaryCic: subsidiaryCic)
        self.restoreSession()
    }
    
    func isRegistrationComplete(subsidiaryCic: String) async throws -> Bool {
        return try await self.sessionRepository.isRegistrationComplete(subsidiaryCic: subsidiaryCic)
    }
    
    func register(registerStuff: RegisterStuffs) async throws {
        let session = try await self.sessionRepository.register(registerStuff: registerStuff)
        print("[SessionManager] Logged in, register")
        self.state = .loggedIn(session)
    }
    
    func restoreSession() {
        if let saved = sessionRepository.loadSession() {
            print("[SessionManager] Logged in, restoreSession")
            self.state = .loggedIn(saved)
        }
    }
}
