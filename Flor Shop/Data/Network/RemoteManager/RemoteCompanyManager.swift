//
//  RemoteCompanyManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteCompanyManager {
    func save(company: Company) async throws
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncCompanyResponse
    func getTokens(localTokens: VerifySyncParameters) async throws -> VerifySyncParameters
}

final class RemoteCompanyManagerImpl: RemoteCompanyManager {
    func save(company: Company) async throws {
        let urlRoute = APIEndpoint.Company.base
        let companyDTO = company.toCompanyDTO()
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: companyDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncCompanyResponse {
        let urlRoute = APIEndpoint.Company.sync
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncCompanyParameters(updatedSince: updatedSinceFormated, syncIds: syncTokens)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: SyncCompanyResponse = try await NetworkManager.shared.perform(request, decodeTo: SyncCompanyResponse.self)
        return data
    }
    func getTokens(localTokens: VerifySyncParameters) async throws -> VerifySyncParameters {
        let urlRoute = APIEndpoint.Sync.base
        let requestParameters = localTokens
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: requestParameters)
        let data: VerifySyncParameters = try await NetworkManager.shared.perform(request, decodeTo: VerifySyncParameters.self)
        return data
    }
}
