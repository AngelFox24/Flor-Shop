
//  RemoteProductManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/01/24.

import Foundation

protocol RemoteProductManager {
    func save(product: Product) async throws
    func sync(updatedSince: String) async throws -> [ProductDTO]
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
    func sync(updatedSince: String) async throws -> [ProductDTO] {
        let urlRoute = "/products/sync"
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: self.sessionConfig.subsidiaryId, updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [ProductDTO] = try await NetworkManager.shared.perform(request, decodeTo: [ProductDTO].self)
        return data
    }
}
