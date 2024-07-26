//
//  RemoteCompanyManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteCompanyManager {
    func save(company: Company) async throws
    func sync(updatedSince: String) async throws -> CompanyDTO
    func logIn(userName: String, password: String) async throws -> CompanyDTO
}

final class RemoteCompanyManagerImpl: RemoteCompanyManager {
    func save(company: Company) async throws {
        let urlRoute = "/companies"
        let companyDTO = company.toCompanyDTO()
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: companyDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: String) async throws -> CompanyDTO {
        let urlRoute = "/subsidiaries/sync"
        let syncParameters = SyncCompanyParameters(updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: CompanyDTO = try await NetworkManager.shared.perform(request, decodeTo: CompanyDTO.self)
        return data
    }
    func logIn(userName: String, password: String) async throws -> CompanyDTO {
        let urlRoute = "/companies/sync"
        let loginParameters = LoginParameters(userName: userName, password: password)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: loginParameters)
        let data: CompanyDTO = try await NetworkManager.shared.perform(request, decodeTo: CompanyDTO.self)
        return data
    }
}
