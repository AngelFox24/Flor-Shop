//
//  RemoteSaleManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

protocol RemoteSaleManager {
    func save(saleDTO: SaleDTO) async throws
    func sync(subsidiaryId: UUID, updatedSince: String) async throws -> [SaleDTO]
}

final class RemoteSaleManagerImpl: RemoteSaleManager {
    func save(saleDTO: SaleDTO) async throws {
        let urlRoute = "/sales"
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: saleDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(subsidiaryId: UUID, updatedSince: String) async throws -> [SaleDTO] {
        let urlRoute = "/sales/sync"
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: subsidiaryId, updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [SaleDTO] = try await NetworkManager.shared.perform(request, decodeTo: [SaleDTO].self)
        return data
    }
}
