import Foundation
import FlorShopDTOs

protocol RemoteSyncManager {
    func sync(globalSyncToken: Int64, branchSyncToken: Int64) async throws -> SyncResponse
}

final class RemoteSyncManagerImpl: RemoteSyncManager {
    let sessionConfig: SessionConfig
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    func sync(globalSyncToken: Int64, branchSyncToken: Int64) async throws -> SyncResponse {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw NetworkError.dataNotFound
        }
        let request = FlorShopCoreApiRequest.sync(
            syncParams: SyncRequest(globalSyncToken: globalSyncToken, branchSyncToken: branchSyncToken),
            token: ScopedTokenWithSubdomain(scopedToken: scopedToken.accessToken, subdomain: self.sessionConfig.subdomain)
        )
        let data: SyncResponse = try await NetworkManager.shared.perform(request, decodeTo: SyncResponse.self)
        return data
    }
}
