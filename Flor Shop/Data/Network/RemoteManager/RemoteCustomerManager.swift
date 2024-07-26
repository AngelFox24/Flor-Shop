//
//  RemoteCustomerManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteCustomerManager {
    func save(customer: Customer) async throws
    func sync(updatedSince: String) async throws -> [CustomerDTO]
}

final class RemoteCustomerManagerImpl: RemoteCustomerManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(customer: Customer) async throws {
        let urlRoute = "/customers"
        let customerDTO = customer.toCustomerDTO(companyId: self.sessionConfig.companyId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: customerDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: String) async throws -> [CustomerDTO] {
        let urlRoute = "/customers/sync"
        let syncParameters = SyncFromCompanyParameters(companyId: self.sessionConfig.companyId, updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [CustomerDTO] = try await NetworkManager.shared.perform(request, decodeTo: [CustomerDTO].self)
        return data
    }
}
