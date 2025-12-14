import Foundation
import FlorShopDTOs

protocol RemoteCompanyManager {
    func save(company: Company) async throws
    func register(registerParams: RegisterParameters) async throws
}

final class RemoteCompanyManagerImpl: RemoteCompanyManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(company: Company) async throws {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.saveCompany(
            company: company.toCompanyDTO(),
            token: ScopedTokenWithSubdomain(scopedToken: scopedToken.accessToken, subdomain: self.sessionConfig.subdomain)
        )
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func register(registerParams: RegisterParameters) async throws {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.register(
            register: registerParams,
            token: ScopedTokenWithSubdomain(scopedToken: scopedToken.accessToken, subdomain: self.sessionConfig.subdomain)
        )
        let data: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
