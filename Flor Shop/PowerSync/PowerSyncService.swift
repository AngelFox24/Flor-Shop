import Foundation
import PowerSync

final class PowerSyncService {
    let db: PowerSyncDatabaseProtocol
    let schema = FlorShopCoreSchema
    let connector: PowerSyncBackendConnectorProtocol
    
    private(set) var isInitialSyncCompleted: Bool = false
    private var statusTask: Task<Void, Never>?
    
    init(sessionConfig: SessionConfig) {
        print("[PowerSyncService] Initializing...")
        self.db = PowerSyncDatabase(
            schema: schema,
            dbFilename: "florshopcore.sqlite",
            logger: DefaultLogger(minSeverity: .debug)
        )
        self.connector = PostgresConnector(sessionConfig: sessionConfig)
    }
    func connect() async throws {
        try await db.connect(connector: connector, options: nil)
    }
    
    func disconnect() async throws {
        try await db.disconnect()
    }
    
    func waitForFirstSync() async throws {
        try await db.waitForFirstSync()
    }
}
