//
//  RemoteSubsidiaryManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteSubsidiaryManager {
    func save(companyId: UUID, subsidiary: Subsidiary) async throws
    func sync(companyId: UUID, updatedSince: String) async throws -> [Subsidiary]
}

final class RemoteSubsidiaryManagerImpl: RemoteSubsidiaryManager {
    func save(companyId: UUID, subsidiary: Subsidiary) async throws {
        let urlRoute = "/subsidiaries"
        let subsidiaryDTO = subsidiary.toSubsidiaryDTO(companyId: companyId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: subsidiaryDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(companyId: UUID, updatedSince: String) async throws -> [Subsidiary] {
        let urlRoute = "/subsidiaries/sync"
        let syncParameters = SyncFromCompanyParameters(companyId: companyId, updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [SubsidiaryDTO] = try await NetworkManager.shared.perform(request, decodeTo: [SubsidiaryDTO].self)
        return data.mapToListSubsidiary()
    }
}
