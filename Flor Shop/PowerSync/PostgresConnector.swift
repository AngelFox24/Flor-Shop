import PowerSync
import FlorShopNetworking

final class PostgresConnector: PowerSyncBackendConnectorProtocol {
    let powerSyncEndpoint: String = AppConfig.powerSyncWS
    let sessionConfig: SessionConfig
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    func fetchCredentials() async throws -> PowerSync.PowerSyncCredentials? {
        guard let scopedToken = try await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: self.sessionConfig.subsidiaryCic)) else {
            throw LocalStorageError.fetchFailed("ScopedToken no encontrado")
        }
        return PowerSync.PowerSyncCredentials(
            endpoint: powerSyncEndpoint,
            token: scopedToken.accessToken
        )
    }
    
    func uploadData(database: any PowerSync.PowerSyncDatabaseProtocol) async throws {
        // Por ahora no hacemos push de datos locales al backend.
            // PowerSync seguirá funcionando en modo read-only sync.
    }
}
