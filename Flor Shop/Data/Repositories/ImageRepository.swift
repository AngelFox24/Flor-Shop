//
//  ImageRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/24.
//

import Foundation
import SwiftUI

protocol ImageRepository {
    func sync() async throws
    func deleteUnusedImages() async
    func loadSavedImage(id: UUID) -> UIImage?
    func downloadImage(url: URL) async -> UIImage?
    func save(idImage: UUID, image: UIImage) -> ImageUrl?
    func save(image: ImageUrl) throws -> ImageUrl
}

class ImageRepositoryImpl: ImageRepository, Syncronizable {
    let localManager: LocalImageManager
    let remoteManager: RemoteImageManager
    let cloudBD = true
    init(
        localManager: LocalImageManager,
        remoteManager: RemoteImageManager
    ) {
        self.localManager = localManager
        self.remoteManager = remoteManager
    }
    func save(image: ImageUrl) throws -> ImageUrl {
        return try self.localManager.save(image: image)
    }
    func sync() async throws {
        var counter = 0
        var items = 0
        
        repeat {
            print("Counter: \(counter)")
            counter += 1
            let updatedSinceString = ISO8601DateFormatter().string(from: localManager.getLastUpdated())
            let imagesDTOs = try await self.remoteManager.sync(updatedSince: updatedSinceString)
            items = imagesDTOs.count
            try self.localManager.sync(imageURLsDTOs: imagesDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func deleteUnusedImages() async {
        await self.localManager.deleteUnusedImages()
    }
    func loadSavedImage(id: UUID) -> UIImage? {
        return self.localManager.loadSavedImage(id: id)
    }
    func downloadImage(url: URL) async -> UIImage? {
        return await self.localManager.downloadImage(url: url)
    }
    func save(idImage: UUID, image: UIImage) -> ImageUrl? {
        return self.localManager.save(idImage: idImage, image: image)
    }
}
