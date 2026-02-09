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
        print("[PowerSyncService] Connecting to database...")
        try await db.connect(connector: connector, options: nil)
        print("[PowerSyncService] End of connection.")
    }
    
    func disconnect() async throws {
        print("[PowerSyncService] Disconnecting from database...")
        try await db.disconnect()
        print("[PowerSyncService] End of disconnection from database...")
    }
    
    func waitForFirstSync() async throws {
        print("[PowerSyncService] Waiting for first sync...")
        try await db.waitForFirstSync()
        print("[PowerSyncService] End of first sync.")
    }
}
