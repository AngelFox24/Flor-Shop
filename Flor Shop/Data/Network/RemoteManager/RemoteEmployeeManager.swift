//
//  RemoteEmployeeManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteEmployeeManager {
    func save(subsidiaryId: UUID, employee: Employee) async throws
    func sync(subsidiaryId: UUID, updatedSince: String) async throws -> [Employee]
}

final class RemoteEmployeeManagerImpl: RemoteEmployeeManager {
    func save(subsidiaryId: UUID, employee: Employee) async throws {
        let urlRoute = "/employees"
        let employeeDTO = employee.toEmployeeDTO(subsidiaryId: subsidiaryId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: employeeDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(subsidiaryId: UUID, updatedSince: String) async throws -> [Employee] {
        let urlRoute = "/employees/sync"
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: subsidiaryId, updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [EmployeeDTO] = try await NetworkManager.shared.perform(request, decodeTo: [EmployeeDTO].self)
        return data.mapToListEmployee()
    }
}
