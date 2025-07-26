import Foundation

protocol RemoteSyncManager {
    func sync(lastToken: Int64) async throws -> SyncClientParameters
}

final class RemoteSyncManagerImpl: RemoteSyncManager {
    let sessionConfig: SessionConfig
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    ///Se le envia "sessionConfig" para sincronizar solo del alcanze de la subsidiaria, con el objetivo de optimizar la sincronizacion y no traer cambios de otras subsidiarias.
    func sync(lastToken: Int64) async throws -> SyncClientParameters {
        let urlRoute = APIEndpoint.Sync.base
        let syncParameters = SyncServerParameters(syncToken: lastToken, sessionConfig: self.sessionConfig)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: SyncClientParameters = try await NetworkManager.shared.perform(request, decodeTo: SyncClientParameters.self)
        return data
    }
}
