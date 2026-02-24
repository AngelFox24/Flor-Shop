import Foundation
import FlorShopDTOs

protocol RemoteCompanyManager {
    func save(company: Company) async throws
    func initialData() async throws
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
            token: scopedToken.accessToken
        )
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func initialData() async throws {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.register(
            token: scopedToken.accessToken
        )
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
