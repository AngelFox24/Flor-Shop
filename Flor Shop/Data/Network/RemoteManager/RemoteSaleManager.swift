//
//  RemoteSaleManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

protocol RemoteSaleManager {
    func save(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws
    func sync(updatedSince: Date) async throws -> [SaleDTO]
}

final class RemoteSaleManagerImpl: RemoteSaleManager {
    let sessionConfig: SessionConfig
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    func save(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws {
        let urlRoute = "/sales"
        let cartDTO = cart.toCartDTO(subsidiaryId: self.sessionConfig.subsidiaryId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: cartDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: Date) async throws -> [SaleDTO] {
        let urlRoute = "/sales/sync"
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: self.sessionConfig.subsidiaryId, updatedSince: updatedSinceFormated)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [SaleDTO] = try await NetworkManager.shared.perform(request, decodeTo: [SaleDTO].self)
        return data
    }
}

struct SaleTransactionDTO: Codable {
    let subsidiaryId: UUID
    let employeeId: UUID
    let customerId: UUID?
    let paymentType: String
    let cart: CartDTO
}
