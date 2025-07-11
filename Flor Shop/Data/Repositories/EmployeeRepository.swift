//
//  EmployeeRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol EmployeeRepository {
    func save(employee: Employee) async throws
    func getEmployees() -> [Employee]
}

class EmployeeRepositoryImpl: EmployeeRepository, Syncronizable {
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
    func sync(backgroundContext: NSManagedObjectContext, syncTokens: VerifySyncParameters) async throws -> VerifySyncParameters {
        var counter = 0
        var items = 0
        var responseSyncTokens = syncTokens
        repeat {
            print("Counter: \(counter)")
            counter += 1
            let updatedSince = self.localManager.getLastUpdated()
            let response = try await self.remoteManager.sync(updatedSince: updatedSince, syncTokens: responseSyncTokens)
            items = response.employeesDTOs.count
            responseSyncTokens = response.syncIds
            try self.localManager.sync(backgroundContext: backgroundContext, employeesDTOs: response.employeesDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
        return responseSyncTokens
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
