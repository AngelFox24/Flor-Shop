//
//  EmployeeRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol EmployeeRepository {
    func sync() async throws
    func save(employee: Employee)
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
    func sync() async throws {
        var counter = 0
        var items = 0
        
        repeat {
            print("Counter: \(counter)")
            counter += 1
            let updatedSinceString = ISO8601DateFormatter().string(from: localManager.getLastUpdated())
            let employeesDTOs = try await self.remoteManager.sync(updatedSince: updatedSinceString)
            items = employeesDTOs.count
            try self.localManager.sync(employeesDTOs: employeesDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func save(employee: Employee) {
        self.localManager.save(employee: employee)
    }
    func getEmployees() -> [Employee] {
        return self.localManager.getEmployees()
    }
}