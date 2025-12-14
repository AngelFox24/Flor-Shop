import Foundation
import CoreData
import FlorShopDTOs

protocol EmployeeRepository: Syncronizable {
    func save(employee: Employee) async throws
    func getEmployees() -> [Employee]
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
    func getLastToken() -> Int64 {
        return 0
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        return self.localManager.getLastToken(context: context)
    }
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncResponse) async throws {
        try self.localManager.sync(backgroundContext: backgroundContext, employeesDTOs: syncDTOs.employees)
    }
    func save(employee: Employee) async throws {
        if cloudBD {
            try await self.remoteManager.save(employee: employee)
        } else {
            try self.localManager.save(employee: employee)
        }
    }
    func getEmployees() -> [Employee] {
        return self.localManager.getEmployees()
    }
}
