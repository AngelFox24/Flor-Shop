import Foundation
import SwiftUI
import CoreData

protocol ImageRepository {
//    func save(image: ImageUrl) async throws -> ImageUrl
    func getImage(image: UIImage) async throws -> ImageUrl
    func deleteUnusedImages() async
}

class ImageRepositoryImpl: ImageRepository, Syncronizable {
    let localManager: LocalImageManager
    let cloudBD = true
    init(
        localManager: LocalImageManager
    ) {
        self.localManager = localManager
    }
    func getLastToken() -> Int64 {
        return 0
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        return self.localManager.getLastToken(context: context)
    }
    func getImage(image: UIImage) async throws -> ImageUrl {
        return try await self.localManager.getImage(image: image)
    }
    func sync(backgroundContext: NSManagedObjectContext, syncDTOs: SyncClientParameters) async throws {
        try self.localManager.sync(backgroundContext: backgroundContext, imageURLsDTOs: syncDTOs.images)
    }
    func deleteUnusedImages() async {
        await self.localManager.deleteUnusedImages()
    }
}
