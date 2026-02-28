import Foundation
import PowerSync
import FlorShopDTOs

protocol LocalEmployeeManager {
    func getEmployees() async throws -> [Employee]
    func isEmployeeProfileComplete() async throws -> Bool
    func getEmployee(employeeCic: String) async throws -> Employee
    func isOwnProfile(employeeCic: String) -> Bool
}

final class SQLiteEmployeeManager: LocalEmployeeManager {
    let sessionConfig: SessionConfig
    let db: PowerSyncDatabaseProtocol
    init(
        sessionConfig: SessionConfig,
        db: PowerSyncDatabaseProtocol
    ) {
        self.sessionConfig = sessionConfig
        self.db = db
    }
    func getEmployees() async throws -> [Employee] {
        print("[SQLiteLocalEmployeeManager] get employees")
        
        let sql = """
                SELECT
                    e.employee_cic,
                    e.name,
                    e.last_name,
                    e.email,
                    e.phone_number,
                    e.image_url,
                    es.role,
                    es.active
                FROM employees e
                INNER JOIN employees_subsidiaries es
                    ON es.employee_id = e.id
                ORDER BY e.name ASC
            """
        
        return try await db.getAll(
            sql: sql,
            parameters: [],
            mapper: { cursor in
                guard let roleEnum = UserSubsidiaryRole(
                    rawValue: try cursor.getString(name: "role")
                ) else {
                    throw NSError(domain: "MapperError", code: 0)
                }
                
                return try Employee(
                    id: UUID(), // o el real si lo tienes
                    employeeCic: cursor.getString(name: "employee_cic"),
                    name: cursor.getString(name: "name"),
                    email: cursor.getString(name: "email"),
                    lastName: cursor.getStringOptional(name: "last_name"),
                    role: roleEnum,
                    imageUrl: cursor.getStringOptional(name: "image_url"),
                    active: cursor.getBoolean(name: "active"),
                    phoneNumber: cursor.getStringOptional(name: "phone_number")
                )
            }
        )
    }
    func isEmployeeProfileComplete() async throws -> Bool {
        let sql = """
            SELECT 1
            FROM employees e
            INNER JOIN employees_subsidiaries es
                ON es.employee_id = e.id
            INNER JOIN subsidiaries s
                ON s.id = es.subsidiary_id
            WHERE e.employee_cic = ?
              AND s.subsidiary_cic = ?
            LIMIT 1
            """
        
        let results: [Int] = try await db.getAll(
            sql: sql,
            parameters: [
                sessionConfig.employeeCic,
                sessionConfig.subsidiaryCic
            ],
            mapper: { cursor in
                try cursor.getInt(index: 0)
            }
        )
        
        return !results.isEmpty
    }
    func getEmployee(employeeCic: String) async throws -> Employee {
        let sql = """
            SELECT
                e.employee_cic,
                e.name,
                e.last_name,
                e.email,
                e.phone_number,
                e.image_url,
                es.role,
                es.active
            FROM employees e
            INNER JOIN employees_subsidiaries es
                ON es.employee_id = e.id
            INNER JOIN subsidiaries s
                ON s.id = es.subsidiary_id
            WHERE e.employee_cic = ?
              AND s.subsidiary_cic = ?
            LIMIT 1
            """

        let results: [Employee] = try await db.getAll(
            sql: sql,
            parameters: [
                employeeCic,
                sessionConfig.subsidiaryCic
            ],
            mapper: { cursor in
                guard let roleEnum = UserSubsidiaryRole(
                    rawValue: try cursor.getString(name: "role")
                ) else {
                    throw NSError(domain: "MapperError", code: 0)
                }

                return try Employee(
                    id: UUID(),
                    employeeCic: cursor.getStringOptional(name: "employee_cic"),
                    name: cursor.getString(name: "name"),
                    email: cursor.getString(name: "email"),
                    lastName: cursor.getStringOptional(name: "last_name"),
                    role: roleEnum,
                    imageUrl: cursor.getStringOptional(name: "image_url"),
                    active: cursor.getBoolean(name: "active"),
                    phoneNumber: cursor.getStringOptional(name: "phone_number")
                )
            }
        )
        guard let employee = results.first else {
            throw LocalStorageError.entityNotFound("Empleado no encontrado")
        }
        return employee
    }
    func isOwnProfile(employeeCic: String) -> Bool {
        self.sessionConfig.employeeCic == employeeCic
    }
}
