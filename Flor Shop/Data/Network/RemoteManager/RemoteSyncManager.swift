import Foundation

protocol RemoteSyncManager {
    func sync(lastToken: Int64) async throws -> Int64
}

final class RemoteSyncManagerImpl: RemoteSyncManager {
    let sessionConfig: SessionConfig
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    ///Se le envia "sessionConfig" para sincronizar solo del alcanze de la subsidiaria, con el objetivo de optimizar la sincronizacion y no traer cambios de otras subsidiarias.
    func sync(lastToken: Int64) async throws -> Int64 {
        let urlRoute = APIEndpoint.Sync.base
        let syncParameters = SyncServerRequestParameters(lastToken: lastToken, sessionConfig: self.sessionConfig)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: Int64 = try await NetworkManager.shared.perform(request, decodeTo: Int64.self)
        return data
    }
}
