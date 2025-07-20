//
//  RemoteCustomerManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

protocol RemoteCustomerManager {
    func save(customer: Customer) async throws
    func payDebt(customerId: UUID, amount: Int) async throws -> Int
//    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncCustomersResponse
}

final class RemoteCustomerManagerImpl: RemoteCustomerManager {
    let sessionConfig: SessionConfig
    init(
        sessionConfig: SessionConfig
    ) {
        self.sessionConfig = sessionConfig
    }
    func save(customer: Customer) async throws {
        let urlRoute = APIEndpoint.Customer.base
        let customerDTO = customer.toCustomerDTO(companyId: self.sessionConfig.companyId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: customerDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func payDebt(customerId: UUID, amount: Int) async throws -> Int {
        let urlRoute = APIEndpoint.Customer.payDebt
        let payCustomerDebt = PayCustomerDebtParameters(customerId: customerId, amount: amount)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: payCustomerDebt)
        let response: PayCustomerDebtResponse = try await NetworkManager.shared.perform(request, decodeTo: PayCustomerDebtResponse.self)
        return response.change
    }
//    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncCustomersResponse {
//        let urlRoute = APIEndpoint.Customer.sync
//        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
//        let syncParameters = SyncFromCompanyParameters(companyId: self.sessionConfig.companyId, updatedSince: updatedSinceFormated, syncIds: syncTokens)
//        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
//        let data: SyncCustomersResponse = try await NetworkManager.shared.perform(request, decodeTo: SyncCustomersResponse.self)
//        return data
//    }
}
