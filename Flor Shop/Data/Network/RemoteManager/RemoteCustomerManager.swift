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
    func sync(updatedSince: Date) async throws -> [CustomerDTO]
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
    func payDebt(customerId: UUID, amount: Int) async throws -> Int {
        let urlRoute = "/customers/payDebt"
        let payCustomerDebt = PayCustomerDebt(customerId: customerId, amount: amount, change: nil)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: payCustomerDebt)
        let response: PayCustomerDebt = try await NetworkManager.shared.perform(request, decodeTo: PayCustomerDebt.self)
        return response.change ?? 0
    }
    func sync(updatedSince: Date) async throws -> [CustomerDTO] {
        let urlRoute = "/customers/sync"
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncFromCompanyParameters(companyId: self.sessionConfig.companyId, updatedSince: updatedSinceFormated)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [CustomerDTO] = try await NetworkManager.shared.perform(request, decodeTo: [CustomerDTO].self)
        return data
    }
}

struct PayCustomerDebt: Codable {
    let customerId: UUID
    let amount: Int
    let change: Int?
}
