import Foundation
import FlorShopDTOs

protocol RemoteSubsidiaryManager {
    func save(subsidiary: Subsidiary) async throws
}

final class RemoteSubsidiaryManagerImpl: RemoteSubsidiaryManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(subsidiary: Subsidiary) async throws {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.saveSubsidiary(
            subsidiary: subsidiary.toSubsidiaryDTO(),
            token: ScopedTokenWithSubdomain(scopedToken: scopedToken.accessToken, subdomain: self.sessionConfig.subdomain)
        )
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
