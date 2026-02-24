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
    
    func login(provider: AuthProvider,token: String) async throws -> [CompanyResponseDTO] {
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
        print("[SessionManager] Logged in, selectSubsidiary")
        await self.loginOk(session: session)
        return session
    }
    
    func register(registerStuff: RegisterStuffs) async throws {
        let session = try await self.sessionRepository.register(registerStuff: registerStuff)
        print("[SessionManager] Logged in, selectSubsidiary")
        await self.loginOk(session: session)
    }
    
    func restoreSession() async {
        if let saved = sessionRepository.loadSession() {
            print("[SessionManager] Logged in, restoreSession")
            await self.loginOk(session: saved)
        }
    }
    private func loginOk(session: SessionConfig) async {
        await MainActor.run {
            self.state = .loggedIn(session)
        }
    }
}
