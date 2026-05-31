import Foundation
import FlorShopDTOs
import FlorShopNetworking

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
            throw LocalStorageError.invalidInput("[RemoteSubsidiaryManagerImpl] Scoped token is invalid")
        }
        let request = FlorShopCoreApiRequest.saveSubsidiary(
            subsidiary: subsidiary.toSubsidiaryDTO(),
            token: scopedToken.accessToken
        )
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
}
