import Foundation
import PowerSync
import FlorShopDTOs

protocol LocalSubsidiaryManager {
    func initialDataExist() async throws -> Bool
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
    func initialDataExist() async throws -> Bool {
        let companyExists = try await companyExists()
        let subsidiaryExists = try await subsidiaryExists()
        return companyExists && subsidiaryExists
    }

    private func companyExists() async throws -> Bool {
        let sql = """
            SELECT 1
            FROM companies
            WHERE company_cic = ?
            LIMIT 1
            """
        
        let results: [Int] = try await db.getAll(
            sql: sql,
            parameters: [sessionConfig.companyCic],
            mapper: { cursor in
                try cursor.getInt(index: 0)
            }
        )
        
        return !results.isEmpty
    }
    
    private func subsidiaryExists() async throws -> Bool {
        let sql = """
            SELECT 1
            FROM subsidiaries
            WHERE subsidiary_cic = ?
              AND company_cic = ?
            LIMIT 1
            """
        
        let results: [Int] = try await db.getAll(
            sql: sql,
            parameters: [
                sessionConfig.subsidiaryCic,
                sessionConfig.companyCic
            ],
            mapper: { cursor in
                try cursor.getInt(index: 0)
            }
        )
        
        return !results.isEmpty
    }
}
