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
        restoreSession()
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
        state = .loggedOut
    }
    
    func selectSubsidiary(subsidiaryCic: String) async throws {
        let session = try await self.sessionRepository.selectSubsidiary(subsidiaryCic: subsidiaryCic)
        self.state = .loggedIn(session)
    }
    
    func register(registerStuff: RegisterStuffs) async throws {
        let session = try await self.sessionRepository.register(registerStuff: registerStuff)
        self.state = .loggedIn(session)
    }
    
    private func restoreSession() {
        if let saved = sessionRepository.loadSession() {
            self.state = .loggedIn(saved)
        }
    }
}
