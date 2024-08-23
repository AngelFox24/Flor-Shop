//
//  RemoteSubsidiaryManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteSubsidiaryManager {
    func save(subsidiary: Subsidiary) async throws
    func sync(updatedSince: Date) async throws -> [SubsidiaryDTO]
}

final class RemoteSubsidiaryManagerImpl: RemoteSubsidiaryManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(subsidiary: Subsidiary) async throws {
        let urlRoute = "/subsidiaries"
        let subsidiaryDTO = subsidiary.toSubsidiaryDTO(companyId: self.sessionConfig.companyId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: subsidiaryDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: Date) async throws -> [SubsidiaryDTO] {
        let urlRoute = "/subsidiaries/sync"
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncFromCompanyParameters(companyId: self.sessionConfig.companyId, updatedSince: updatedSinceFormated)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [SubsidiaryDTO] = try await NetworkManager.shared.perform(request, decodeTo: [SubsidiaryDTO].self)
        return data
    }
}
