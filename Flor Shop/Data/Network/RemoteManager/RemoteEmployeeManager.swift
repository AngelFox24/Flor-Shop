//
//  RemoteEmployeeManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteEmployeeManager {
    func save(employee: Employee) async throws
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncEmployeesResponse
}

final class RemoteEmployeeManagerImpl: RemoteEmployeeManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(employee: Employee) async throws {
        let urlRoute = APIEndpoint.Employee.base
        let employeeDTO = employee.toEmployeeDTO(subsidiaryId: self.sessionConfig.subsidiaryId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: employeeDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncEmployeesResponse {
        let urlRoute = APIEndpoint.Employee.sync
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: self.sessionConfig.subsidiaryId, updatedSince: updatedSinceFormated, syncIds: syncTokens)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: SyncEmployeesResponse = try await NetworkManager.shared.perform(request, decodeTo: SyncEmployeesResponse.self)
        return data
    }
}
