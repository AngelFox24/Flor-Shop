//
//  RemoteCompanyManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteCompanyManager {
    func save(company: Company) async throws
    func sync(updatedSince: Date) async throws -> CompanyDTO
}

final class RemoteCompanyManagerImpl: RemoteCompanyManager {
    func save(company: Company) async throws {
        let urlRoute = "/companies"
        let companyDTO = company.toCompanyDTO()
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: companyDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: Date) async throws -> CompanyDTO {
        let urlRoute = "/companies/sync"
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncCompanyParameters(updatedSince: updatedSinceFormated)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: CompanyDTO = try await NetworkManager.shared.perform(request, decodeTo: CompanyDTO.self)
        return data
    }
}
