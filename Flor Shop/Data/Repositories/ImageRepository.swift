import Foundation
import UIKit

protocol ImageRepository {
//    func getImage(url: URL) async throws -> UIImage
    func getOptimizedImage(uiImage: UIImage) throws -> UIImage
    func saveImage(uiImage: UIImage) async throws -> URL
}

class ImageRepositoryImpl: ImageRepository {
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
    ///Se reducen y optimizan para ser mostrado en la pantalla sin mucho esfuerzo.
    func getOptimizedImage(uiImage: UIImage) throws -> UIImage {
        return try self.localManager.getOptimizedImage(uiImage: uiImage)
    }
    ///Guarda imágenes que provienen de photos, si tiene premium debe guardar en la nube para que otros lo puedan ver a travéz de una URL
    func saveImage(uiImage: UIImage) async throws -> URL {
        let optimizedImage = try self.localManager.getOptimizedImage(uiImage: uiImage)
        if cloudBD {
            guard let imageData = optimizedImage.jpegData(compressionQuality: 1.0) else {
                throw LocalStorageError.invalidInput("No se puede convertir de Data a UIImage")
            }
            let cloudUrl = try await self.remoteManager.save(imageData: imageData)
            return cloudUrl
        } else {
            throw LocalStorageError.invalidInput("No se puede guardar en la nube")
        }
    }
}
