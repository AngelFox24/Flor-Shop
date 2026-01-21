import Foundation
import PowerSync
import FlorShopDTOs

protocol LocalSubsidiaryManager {
    func getSubsidiaries() async throws -> [Subsidiary]
}

final class SQLiteSubsidiaryManager: LocalSubsidiaryManager {
    let sessionConfig: SessionConfig
    let db: PowerSyncDatabaseProtocol
    init(
        sessionConfig: SessionConfig,
        db: PowerSyncDatabaseProtocol
    ) {
        self.sessionConfig = sessionConfig
        self.db = db
    }
    func getSubsidiaries() async throws -> [Subsidiary] {
        []
    }
}
