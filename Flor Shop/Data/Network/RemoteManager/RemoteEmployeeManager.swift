//
//  RemoteEmployeeManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteEmployeeManager {
    func save(employee: Employee) async throws
    func sync(updatedSince: String) async throws -> [EmployeeDTO]
}

final class RemoteEmployeeManagerImpl: RemoteEmployeeManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(employee: Employee) async throws {
        let urlRoute = "/employees"
        let employeeDTO = employee.toEmployeeDTO(subsidiaryId: self.sessionConfig.subsidiaryId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: employeeDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: String) async throws -> [EmployeeDTO] {
        let urlRoute = "/employees/sync"
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: self.sessionConfig.subsidiaryId, updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [EmployeeDTO] = try await NetworkManager.shared.perform(request, decodeTo: [EmployeeDTO].self)
        return data
    }
}
