//
//  ImageRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/24.
//

import Foundation
import SwiftUI
import CoreData

protocol ImageRepository {
    func save(image: ImageUrl) async throws -> ImageUrl
    func saveImage(image: UIImage) async throws -> ImageUrl
    func deleteUnusedImages() async
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
    func save(image: ImageUrl) async throws -> ImageUrl {
        if cloudBD {
            return try await self.remoteManager.save(imageUrl: image, imageData: nil)
        } else {
            return try self.localManager.save(image: image)
        }
    }
    func saveImage(image: UIImage) async throws -> ImageUrl {
        if cloudBD {
            let imageData = try await LocalImageManagerImpl.getEfficientImageTreated(image: image)
            let imageHash = LocalImageManagerImpl.generarHash(data: imageData)
            let imageUrl = ImageUrl(id: UUID(), imageUrl: "", imageHash: imageHash, createdAt: Date(), updatedAt: Date())
            return try await self.remoteManager.save(imageUrl: imageUrl, imageData: imageData)
        } else {
            return try await self.localManager.saveImage(image: image)
        }
    }
    func sync(backgroundContext: NSManagedObjectContext) async throws {
        var counter = 0
        var items = 0
        
        repeat {
            print("Counter: \(counter)")
            counter += 1
            let updatedSince = self.localManager.getLastUpdated()
            let imagesDTOs = try await self.remoteManager.sync(updatedSince: updatedSince)
            items = imagesDTOs.count
            try self.localManager.sync(backgroundContext: backgroundContext, imageURLsDTOs: imagesDTOs)
        } while (counter < 200 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func deleteUnusedImages() async {
        await self.localManager.deleteUnusedImages()
    }
}
