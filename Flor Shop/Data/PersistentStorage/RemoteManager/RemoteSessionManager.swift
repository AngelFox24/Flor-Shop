import Foundation
import FlorShopDTOs

protocol RemoteSessionManager {
    func login(provider: AuthProvider, token: String) async throws
    func getCompanies() async throws -> [CompanyResponseDTO]
    func getSubsidiaries(companyCic: String) async throws -> [SubsidiaryResponseDTO]
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig
    func selectSubsidiary(subsidiaryCic: String) async throws -> SessionConfig
    func completeProfile(employee: Employee, subsidiaryCic: String, subdomain: String) async throws
    func isRegistrationComplete(subsidiaryCic: String, subdomain: String) async throws -> Bool
}

final class RemoteSessionManagerMock: RemoteSessionManager {
    func login(provider: AuthProvider, token: String) async throws {}
    func getCompanies() async throws -> [CompanyResponseDTO] {
        [.init(
            company_cic: UUID().uuidString,
            name: "Mock Company 1",
            subdomain: "Mock Subdomain 1",
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
            subdomain: "Mock subdomain",
            companyCic: UUID().uuidString,
            subsidiaryCic: UUID().uuidString,
            employeeCic: UUID().uuidString
        )
    }
    func selectSubsidiary(subsidiaryCic: String) async throws -> SessionConfig {
        return SessionConfig(
            subdomain: "Mock subdomain",
            companyCic: UUID().uuidString,
            subsidiaryCic: subsidiaryCic,
            employeeCic: UUID().uuidString
        )
    }
    func completeProfile(employee: Employee, subsidiaryCic: String, subdomain: String) async throws {
        
    }
    func isRegistrationComplete(subsidiaryCic: String, subdomain: String) async throws -> Bool {
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
            subdomain: payload.subdomain,
            companyCic: payload.companyCic,
            subsidiaryCic: payload.subsidiaryCic,
            employeeCic: payload.sub
        )
    }
    func register(registerStuff: RegisterStuffs) async throws -> SessionConfig {
        let allProviders = AuthProvider.allCases
        var providerToken: TokenRefreshable? = nil
        var providerFounded: AuthProvider? = nil
        for provider in allProviders {
            if let token = try? await TokenManager.shared.getToken(identifier: .providerToken(provider: provider)) {
                providerToken = token
                providerFounded = provider
                break
            }
        }
        guard let providerToken,
              let providerFounded else {
            throw NetworkError.dataNotFound
        }
        guard let registerRequest = RegisterCompanyRequest(from: registerStuff, provider: providerFounded, subdomain: registerStuff.subdomain) else {
            throw NetworkError.invalidResponse
        }
        let request = FlorShopAuthApiRequest.registerCompany(request: registerRequest, providerToken: providerToken.accessToken)
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
            subdomain: payload.subdomain,
            companyCic: payload.companyCic,
            subsidiaryCic: payload.subsidiaryCic,
            employeeCic: payload.sub
        )
    }
    func completeProfile(employee: Employee, subsidiaryCic: String, subdomain: String) async throws {
        guard let scopedToken: TokenRefreshable = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.saveEmployee(
            employee: employee.toEmployeeDTO(),
            token: ScopedTokenWithSubdomain(
                scopedToken: scopedToken.accessToken,
                subdomain: subdomain
            )
        )
        let response: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func isRegistrationComplete(subsidiaryCic: String, subdomain: String) async throws -> Bool {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.isRegistrationComplete(token: ScopedTokenWithSubdomain(scopedToken: scopedToken.accessToken, subdomain: subdomain))
        let response: CompleteRegistrationResponse = try await NetworkManager.shared.perform(request, decodeTo: CompleteRegistrationResponse.self)
        return response.isRegistered
    }
}
