import Foundation
import PowerSync

actor PowerSyncService {
    enum State {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }

    private var state: State = .disconnected
    private(set) var connectCount = 0
    private(set) var disconnectCount = 0
    private let instanceId = UUID()
    
    let db: PowerSyncDatabaseProtocol
    let schema = FlorShopCoreSchema
    let connector: PowerSyncBackendConnectorProtocol

    init(sessionConfig: SessionConfig) {
        print("[PowerSyncService] Initializing \(instanceId)")
        self.db = PowerSyncDatabase(
            schema: schema,
            dbFilename: "florshopcore.sqlite",
            logger: DefaultLogger(minSeverity: .debug)
        )
        self.connector = PostgresConnector(sessionConfig: sessionConfig)
    }

    func connect() async throws {
        guard state == .disconnected else {
            print("[PowerSyncService] Connect ignored. Current state: \(state)")
            return
        }

        connectCount += 1
        print("[PowerSyncService \(instanceId)] Connect request #\(connectCount)")

        state = .connecting

        do {
            print("[PowerSyncService] Connecting to database...")
            try await db.connect(connector: connector, options: nil)
            state = .connected
            print("[PowerSyncService] End of Connecting.")
        } catch {
            state = .disconnected
            throw error
        }
    }

    func disconnect() async throws {
        guard state == .connected else {
            print("[PowerSyncService] Disconnect ignored. Current state: \(state)")
            return
        }

        disconnectCount += 1
        print("[PowerSyncService] Disconnect request #\(disconnectCount)")

        state = .disconnecting

        do {
            print("[PowerSyncService] Disconnecting from database...")
            try await db.disconnect()
            state = .disconnected
            print("[PowerSyncService] End of disconnection from database...")
        } catch {
            state = .connected
            throw error
        }
    }

    func waitForFirstSync() async throws {
        print("[PowerSyncService] Waiting for first sync...")
        try await db.waitForFirstSync()
        print("[PowerSyncService] End of first sync.")
    }
}
