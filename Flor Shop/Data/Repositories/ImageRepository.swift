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
    ///Busca en archivos locales por la URL si no lo encuentra lo descarga de Internet y lo guarda como archivo para luego no volver a descargarlo.
//    func getImage(url: URL) async throws -> UIImage {
//        if url.isFileURL {
//            guard let image = try self.localManager.getImage(url: url) else {
//                throw LocalStorageError.saveFailed("No se pudo optener la imagen de esta URL Path: \(url.absoluteString)")
//            }
//            return image
//        } else if let image = try self.localManager.getImage(url: url) {
//            return image
//        } else {
//            //TODO: Descargamos de internet
//            let image: UIImage = UIImage() // = remoteManager.getImage(url: url)
//            let optimizedImage = try self.localManager.getOptimizedImage(uiImage: image)
//            try self.localManager.saveImageFromInternet(uiImage: optimizedImage, url: url)
//            return optimizedImage
//        }
//    }
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
