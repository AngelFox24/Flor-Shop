//
//  RemoteImageManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 25/07/2024.
//

import Foundation

protocol RemoteImageManager {
    func sync(updatedSince: String) async throws -> [ImageURLDTO]
}

final class RemoteImageManagerImpl: RemoteImageManager {
    func sync(updatedSince: String) async throws -> [ImageURLDTO] {
        let urlRoute = "/images/sync"
        let syncParameters = SyncImageParameters(updatedSince: updatedSince)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: [ImageURLDTO] = try await NetworkManager.shared.perform(request, decodeTo: [ImageURLDTO].self)
        return data
    }
}
