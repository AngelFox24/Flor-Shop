
//  RemoteProductManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/01/24.

import Foundation

protocol RemoteProductManager {
    func save(subsidiaryId: UUID, product: Product) async throws -> Bool
    func sync(subsidiaryId: UUID, updatedSince: String) async throws -> [Product]
}

final class RemoteProductManagerImpl: RemoteProductManager {
    func save(subsidiaryId: UUID, product: Product) async throws -> Bool {
        let urlRoute = "/products"
        let productDTO = product.toProductDTO(subsidiaryId: subsidiaryId)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: productDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
        return true
    }
    func sync(subsidiaryId: UUID, updatedSince: String) async throws -> [Product] {
        let urlRoute = "/products/sync"
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: subsidiaryId, updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [ProductDTO] = try await NetworkManager.shared.perform(request, decodeTo: [ProductDTO].self)
        return data.mapToListProducts()
    }
}
