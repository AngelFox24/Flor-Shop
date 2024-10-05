//
//  RemoteImageManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 25/07/2024.
//

import Foundation

protocol RemoteImageManager {
    func save(imageUrl: ImageUrl, imageData: Data?) async throws -> ImageURLDTO
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncImageUrlResponse
}

final class RemoteImageManagerImpl: RemoteImageManager {
    func save(imageUrl: ImageUrl, imageData: Data?) async throws -> ImageURLDTO {
        let urlRoute = "/imageUrls"
        let imageDTO = imageUrl.toImageUrlDTO(imageData: imageData)
        print("Imagen Date createdAt: \(imageDTO.createdAt) updatedAt: \(imageDTO.updatedAt)")
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: imageDTO)
        let response: ImageURLDTO = try await NetworkManager.shared.perform(request, decodeTo: ImageURLDTO.self)
        return response
    }
    func sync(updatedSince: Date, syncTokens: VerifySyncParameters) async throws -> SyncImageUrlResponse {
        let urlRoute = "/imageUrls/sync"
        let updatedSinceFormated = ISO8601DateFormatter().string(from: updatedSince)
        let syncParameters = SyncImageParameters(updatedSince: updatedSinceFormated, syncIds: syncTokens)
        let request = CustomAPIRequest(urlRoute: urlRoute, parameter: syncParameters)
        let data: SyncImageUrlResponse = try await NetworkManager.shared.perform(request, decodeTo: SyncImageUrlResponse.self)
        return data
    }
}
