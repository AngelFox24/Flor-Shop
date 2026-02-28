import Foundation
import FlorShopDTOs

protocol EmployeeRepository {
    func save(employee: Employee) async throws
    func invite(email: String, role: UserSubsidiaryRole) async throws
    func getEmployees() async throws -> [Employee]
    func isEmployeeProfileComplete() async throws -> Bool
    func getEmployee(employeeCic: String) async throws -> Employee
    func isOwnProfile(employeeCic: String) -> Bool
}

class EmployeeRepositoryImpl: EmployeeRepository {
    let localManager: LocalEmployeeManager
    let remoteManager: RemoteEmployeeManager
    let cloudBD = true
    init(
        localManager: LocalEmployeeManager,
        remoteManager: RemoteEmployeeManager
    ) {
        self.localManager = localManager
        self.remoteManager = remoteManager
    }
    func save(employee: Employee) async throws {
        if cloudBD {
            try await self.remoteManager.save(employee: employee)
        }
    }
    func invite(email: String, role: UserSubsidiaryRole) async throws {
        if cloudBD {
            try await self.remoteManager.invite(email: email, role: role)
        }
    }
    func getEmployees() async throws -> [Employee] {
        return try await self.localManager.getEmployees()
    }
    func isEmployeeProfileComplete() async throws -> Bool {
        return try await self.localManager.isEmployeeProfileComplete()
    }
    func getEmployee(employeeCic: String) async throws -> Employee {
        return try await self.localManager.getEmployee(employeeCic: employeeCic)
    }
    func isOwnProfile(employeeCic: String) -> Bool {
        return self.localManager.isOwnProfile(employeeCic: employeeCic)
    }
}
