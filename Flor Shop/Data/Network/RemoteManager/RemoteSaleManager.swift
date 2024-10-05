//
//  RemoteSaleManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

protocol RemoteSaleManager {
    func save(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncSalesResponse
}

final class RemoteSaleManagerImpl: RemoteSaleManager {
    let sessionConfig: SessionConfig
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    func save(cart: Car, paymentType: PaymentType, customerId: UUID?) async throws {
        let urlRoute = "/sales"
        let cartDTO = cart.toCartDTO(subsidiaryId: self.sessionConfig.subsidiaryId)
        let saleTransactionDTO = RegisterSaleParameters(
            subsidiaryId: self.sessionConfig.subsidiaryId,
            employeeId: self.sessionConfig.employeeId,
            customerId: customerId,
            paymentType: paymentType.description,
            cart: cartDTO
        )
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: saleTransactionDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncSalesResponse {
        let urlRoute = "/sales/sync"
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: self.sessionConfig.subsidiaryId, updatedSince: updatedSinceFormated, syncIds: syncTokens)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: SyncSalesResponse = try await NetworkManager.shared.perform(request, decodeTo: SyncSalesResponse.self)
        return data
    }
}
