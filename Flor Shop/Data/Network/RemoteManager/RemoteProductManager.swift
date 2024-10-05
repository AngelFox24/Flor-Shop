
//  RemoteProductManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/01/24.

import Foundation

protocol RemoteProductManager {
    func save(product: Product) async throws
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncProductsResponse
}

final class RemoteProductManagerImpl: RemoteProductManager {
    let sessionConfig: SessionConfig
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    func save(product: Product) async throws {
        let urlRoute = "/products"
        let productDTO = product.toProductDTO(subsidiaryId: self.sessionConfig.subsidiaryId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: productDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncProductsResponse {
        let urlRoute = "/products/sync"
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: self.sessionConfig.subsidiaryId, updatedSince: updatedSinceFormated, syncIds: syncTokens)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        print("Antes del pedido")
        let data: SyncProductsResponse = try await NetworkManager.shared.perform(request, decodeTo: SyncProductsResponse.self)
        print("Despues del pedido")
        return data
    }
}
