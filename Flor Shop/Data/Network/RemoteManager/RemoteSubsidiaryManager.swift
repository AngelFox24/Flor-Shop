//
//  RemoteSubsidiaryManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteSubsidiaryManager {
    func save(subsidiary: Subsidiary) async throws
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncSubsidiariesResponse
}

final class RemoteSubsidiaryManagerImpl: RemoteSubsidiaryManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(subsidiary: Subsidiary) async throws {
        let urlRoute = APIEndpoint.Subsidiary.base
        let subsidiaryDTO = subsidiary.toSubsidiaryDTO(companyId: self.sessionConfig.companyId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: subsidiaryDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncSubsidiariesResponse {
        let urlRoute = APIEndpoint.Subsidiary.sync
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncFromCompanyParameters(companyId: self.sessionConfig.companyId, updatedSince: updatedSinceFormated, syncIds: syncTokens)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: SyncSubsidiariesResponse = try await NetworkManager.shared.perform(request, decodeTo: SyncSubsidiariesResponse.self)
        return data
    }
}
