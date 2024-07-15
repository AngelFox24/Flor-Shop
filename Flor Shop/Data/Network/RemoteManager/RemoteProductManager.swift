
//  RemoteProductManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/01/24.

import Foundation

protocol RemoteProductManager {
    func save(productDTO: ProductDTO) async throws
    func sync(subsidiaryId: UUID, updatedSince: String) async throws -> [ProductDTO]
}

final class RemoteProductManagerImpl: RemoteProductManager {
    func save(productDTO: ProductDTO) async throws {
        let urlRoute = "/products"
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: productDTO)
        let _: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
    }
    func sync(subsidiaryId: UUID, updatedSince: String) async throws -> [ProductDTO] {
        let urlRoute = "/products/sync"
        let syncParameters = SyncFromSubsidiaryParameters(subsidiaryId: subsidiaryId, updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [ProductDTO] = try await NetworkManager.shared.perform(request, decodeTo: [ProductDTO].self)
        return data
    }
}
