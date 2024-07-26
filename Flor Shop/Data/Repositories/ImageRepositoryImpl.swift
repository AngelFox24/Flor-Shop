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
    func saveImage(idImage: UUID, image: UIImage) -> ImageUrl?
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
    func sync() async throws {
        var counter = 0
        var items = 0
        
        repeat {
            print("Counter: \(counter)")
            counter += 1
            guard let updatedSince = try localManager.getLastUpdated() else {
                throw RepositoryError.invalidFields(("El campo updatedSince no se encuentra"))
            }
            let updatedSinceString = ISO8601DateFormatter().string(from: updatedSince)
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
    func saveImage(idImage: UUID, image: UIImage) -> ImageUrl? {
        return self.localManager.saveImage(idImage: idImage, image: image)
    }
}
