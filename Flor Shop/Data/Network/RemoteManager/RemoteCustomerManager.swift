//
//  RemoteCustomerManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteCustomerManager {
    func save(companyId: UUID, customer: Customer) async throws
    func sync(companyId: UUID, updatedSince: String) async throws -> [Customer]
}

final class RemoteCustomerManagerImpl: RemoteCustomerManager {
    func save(companyId: UUID, customer: Customer) async throws {
        let urlRoute = "/customers"
        let customerDTO = customer.toCustomerDTO(companyId: companyId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: customerDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(companyId: UUID, updatedSince: String) async throws -> [Customer] {
        let urlRoute = "/customers/sync"
        let syncParameters = SyncFromCompanyParameters(companyId: companyId, updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [CustomerDTO] = try await NetworkManager.shared.perform(request, decodeTo: [CustomerDTO].self)
        return data.mapToListCustomers()
    }
}
