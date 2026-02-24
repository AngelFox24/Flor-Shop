import Foundation
import FlorShopDTOs

protocol RemoteSessionManager {
    func login(provider: AuthProvider, token: String) async throws
    func getCompanies() async throws -> [CompanyResponseDTO]
    func getSubsidiaries(companyCic: String) async throws -> [SubsidiaryResponseDTO]
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig
    func selectSubsidiary(subsidiaryCic: String) async throws -> SessionConfig
    func isRegistrationComplete(subsidiaryCic: String) async throws -> Bool
}

final class RemoteSessionManagerMock: RemoteSessionManager {
    func login(provider: AuthProvider, token: String) async throws {}
    func getCompanies() async throws -> [CompanyResponseDTO] {
        [.init(
            company_cic: UUID().uuidString,
            name: "Mock Company 1",
            is_company_owner: true
        )]
    }
    func getSubsidiaries(companyCic: String) async throws -> [SubsidiaryResponseDTO] {
        [.init(
            subsidiary_cic: UUID().uuidString,
            name: "Mock Subsidiary 1",
            subsidiary_role: .cashier
        )]
    }
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig {
        return SessionConfig(
            companyCic: UUID().uuidString,
            subsidiaryCic: UUID().uuidString,
            employeeCic: UUID().uuidString
        )
    }
    func selectSubsidiary(subsidiaryCic: String) async throws -> SessionConfig {
        return SessionConfig(
            companyCic: UUID().uuidString,
            subsidiaryCic: subsidiaryCic,
            employeeCic: UUID().uuidString
        )
    }
    func isRegistrationComplete(subsidiaryCic: String) async throws -> Bool {
        return true
    }
}

final class RemoteSessionManagerImpl: RemoteSessionManager {
    func login(provider: AuthProvider, token: String) async throws {
        let request = FlorShopAuthApiRequest.auth(provider: provider, providerToken: token)
        let data: BaseTokenResponse = try await NetworkManager.shared.perform(request, decodeTo: BaseTokenResponse.self)
        guard let payload = BaseTokenPayload(token: data.baseToken) else {
            throw NetworkError.invalidResponse
        }
        let token = TokenRefreshable(
            id: payload.type,
            identifier: .baseToken,
            accessToken: data.baseToken,
            refreshToken: nil,
            accessTokenExpiry: payload.expiresAt
        )
        await TokenManager.shared.save(token: token)
    }
    func getCompanies() async throws -> [CompanyResponseDTO] {
        guard let baseToken = try await TokenManager.shared.getToken(identifier: .baseToken) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopAuthApiRequest.getCompanies(baseToken: baseToken.accessToken)
        let data: [CompanyResponseDTO] = try await NetworkManager.shared.perform(request, decodeTo: [CompanyResponseDTO].self)
        return data
    }
    func getSubsidiaries(companyCic: String) async throws -> [SubsidiaryResponseDTO] {
        guard let baseToken = try await TokenManager.shared.getToken(identifier: .baseToken) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopAuthApiRequest.getSubsidiaries(companyCic: companyCic, baseToken: baseToken.accessToken)
        let data: [SubsidiaryResponseDTO] = try await NetworkManager.shared.perform(request, decodeTo: [SubsidiaryResponseDTO].self)
        return data
    }
    func selectSubsidiary(subsidiaryCic: String) async throws -> SessionConfig {
        guard let baseToken = try await TokenManager.shared.getToken(identifier: .baseToken) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopAuthApiRequest.selectSubsidiary(subsidiaryCic: subsidiaryCic, baseToken: baseToken.accessToken)
        let data: ScopedTokenWithRefreshResponse = try await NetworkManager.shared.perform(request, decodeTo: ScopedTokenWithRefreshResponse.self)
        guard let payload = ScopedTokenPayload(token: data.scopedToken) else {
            throw NetworkError.invalidResponse
        }
        let token = TokenRefreshable(
            id: payload.type,
            identifier: .scopedToken(subsidiaryCic: payload.subsidiaryCic),
            accessToken: data.scopedToken,
            refreshToken: data.refreshScopedToken,
            accessTokenExpiry: payload.expiresAt
        )
        await TokenManager.shared.save(token: token)
        return SessionConfig(
            companyCic: payload.companyCic,
            subsidiaryCic: payload.subsidiaryCic,
            employeeCic: payload.sub
        )
    }
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig {
        guard let registerRequest = RegisterCompanyRequest(from: registerStuff, provider: registerStuff.authProvider, role: registerStuff.role) else {
            throw NetworkError.invalidResponse
        }
        let request = FlorShopAuthApiRequest.registerCompany(request: registerRequest, providerToken: registerStuff.token)
        let data: ScopedTokenWithRefreshResponse = try await NetworkManager.shared.perform(request, decodeTo: ScopedTokenWithRefreshResponse.self)
        guard let payload = ScopedTokenPayload(token: data.scopedToken) else {
            throw NetworkError.invalidResponse
        }
        let token = TokenRefreshable(
            id: payload.type,
            identifier: .scopedToken(subsidiaryCic: payload.subsidiaryCic),
            accessToken: data.scopedToken,
            refreshToken: data.refreshScopedToken,
            accessTokenExpiry: payload.expiresAt
        )
        await TokenManager.shared.save(token: token)
        return SessionConfig(
            companyCic: payload.companyCic,
            subsidiaryCic: payload.subsidiaryCic,
            employeeCic: payload.sub
        )
    }
    func isRegistrationComplete(subsidiaryCic: String) async throws -> Bool {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.isRegistrationComplete(token: scopedToken.accessToken)
        let response: CompleteRegistrationResponse = try await NetworkManager.shared.perform(request, decodeTo: CompleteRegistrationResponse.self)
        return response.isRegistered
    }
}
