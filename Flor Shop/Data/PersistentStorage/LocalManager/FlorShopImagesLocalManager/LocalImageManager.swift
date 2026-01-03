import Foundation
import CoreData
import SwiftUI
import ImageIO
import CoreGraphics
import MobileCoreServices
import UniformTypeIdentifiers
import CommonCrypto
import FlorShopDTOs

protocol LocalImageManager {
    ///Sirve para obtener una imagen buscando la URL en la BD y luego su archivo en los datos locales
//    func getImage(url: URL) throws -> UIImage?
    ///Sirve para obtener una imagen optimizada a partir de una imagen
    func getOptimizedImage(uiImage: UIImage) throws -> UIImage
    ///Sirve para guardar imagenes en local como archivo, la url proveniente de internet como input tiene la funcion de asociarse a la imagen
//    func saveImageFromInternet(uiImage: UIImage, url: URL) throws //URL de la imagen
    ///Sirve para guardar imagenes en local como archivo, internamente se asocia a una URL de la ruta del archivo
//    func saveImageFromPhotos(uiImage: UIImage) throws -> URL
}

final class LocalImageManagerImpl: LocalImageManager {
    let className = "[LocalImageManager]"
    let fileManager: LocalImageFileManager
    init(
        fileManager: LocalImageFileManager
    ) {
        self.fileManager = fileManager
    }
    //MARK: Main Functions
//    func getImage(url: URL) throws -> UIImage? {
//        let urlString = url.absoluteString
//        if let imageEntity = self.getImageEntityByURL(imageURL: urlString) {
//            guard let hash = imageEntity.imageHash else {
//                throw LocalStorageError.entityNotFound("Image hash is nil for \(urlString)")
//            }
//            let image = try self.fileManager.getImage(hash: hash)
//            return image
//        } else {
//            return nil
//        }
//    }
    func getOptimizedImage(uiImage: UIImage) throws -> UIImage {
        return try self.fileManager.getEfficientImage(uiImage: uiImage)
    }
    //Se supone que la imagen ya esta optimizada
//    func saveImageFromInternet(uiImage: UIImage, url: URL) throws {
//        //no tiene costo optmizar la imagen
//        let hash = try self.fileManager.generarHash(uiImage: uiImage)
//        if let imageEntity = self.getImageEntityByURL(imageURL: url.absoluteString) {
//            guard let entityHash = imageEntity.imageHash else {
//                throw LocalStorageError.entityNotFound("Image hash is nil for \(url.absoluteString)")
//            }
//            if entityHash != hash {
//                //Eliminamos la imagen anterior
//                self.fileManager.deleteImageFile(hash: entityHash)
//                //Guardamos la imagen en fileManager
//                let _ = try self.fileManager.saveImage(uiImage: uiImage, hash: hash)
//                //Actualizamos la imagen
//                imageEntity.imageHash = hash
//                try saveData()
//            }
//            return
//        } else if let imageEntity = self.getImageEntityByHash(imageHash: hash) {
//            guard let imageUrl = imageEntity.imageUrl else {
//                throw LocalStorageError.entityNotFound("Imagen url not found")
//            }
//            if imageUrl != url.absoluteString {
//                //Registramos la URL con la misma imagen hash
//                let newImage = Tb_Image(context: mainContext)
//                newImage.imageHash = hash
//                newImage.imageUrl = url.absoluteString
//                newImage.isUrlLocal = false
//                try saveData()
//            }
//            return
//        } else { //Imagen nueva tanto en hash y url
//            //Save Image
//            let _ = try self.fileManager.saveImage(uiImage: uiImage, hash: hash)
//            let newImage = Tb_Image(context: mainContext)
//            newImage.imageHash = hash
//            newImage.isUrlLocal = false
//            newImage.imageUrl = url.absoluteString
//            try saveData()
//        }
//    }
//    func saveImageFromPhotos(uiImage: UIImage) throws -> URL {
//        //no tiene costo optmizar la imagen
//        let hash = try self.fileManager.generarHash(uiImage: uiImage)
//        if let imageEntity = self.getImageEntityByHash(imageHash: hash) {
//            guard let imageUrl = imageEntity.imageUrl else {
//                throw LocalStorageError.entityNotFound("Imagen url not found")
//            }
//            guard let imageUrl = URL(string: imageUrl) else {
//                throw LocalStorageError.entityNotFound("Image URL not valid")
//            }
//            return imageUrl
//        } else { //Imagen nueva en hash
//            //Save Image
//            let pathUrl = try self.fileManager.saveImage(uiImage: uiImage, hash: hash)
//            let newImage = Tb_Image(context: mainContext)
//            newImage.imageHash = hash
//            newImage.isUrlLocal = true
//            newImage.imageUrl = pathUrl.absoluteString
//            try saveData()
//            return pathUrl
//        }
//    }
    //MARK: Private Funtions
//    private func saveData() throws {
//        do {
//            try self.mainContext.save()
//        } catch {
//            rollback()
//            let cusError: String = "\(className): \(error.localizedDescription)"
//            throw LocalStorageError.saveFailed(cusError)
//        }
//    }
//    private func rollback() {
//        self.mainContext.rollback()
//    }
//    private func shouldSaveImage(imageData: Data) -> Bool {//Talves se pueda eliminar o dejar en uses cases
//        guard let uiImage = UIImage(data: imageData) else {
//            return false
//        }
//        let imageSize = uiImage.size
//        let imageSizeInPixels = Int(imageSize.width) * Int(imageSize.height)
//        let imageSizeInKB = imageData.count / 1024 // Divide entre 1024 para obtener el tamaño en KB
//        let maximumImageSizeInPixels = 1920 * 1080 // Define el tamaño máximo permitido en píxeles
//        let maximumImageSizeInKB = 1024 // Define el tamaño máximo permitido en KB
//        if imageSizeInPixels > maximumImageSizeInPixels || imageSizeInKB > maximumImageSizeInKB {
//            return false
//        }
//        print("La imagen es valida para ser guardada \(imageSizeInPixels.description) ----- \(imageSizeInKB.description)")
//        return true
//    }
//    private func getImageEntityByHash(imageHash: String) -> Tb_Image? {
//        let request: NSFetchRequest<Tb_Image> = Tb_Image.fetchRequest()
//        let predicate = NSPredicate(format: "imageHash == %@", imageHash)
//        request.predicate = predicate
//        do {
//            return try self.mainContext.fetch(request).first
//        } catch {
//            print("Error fetching. \(error)")
//            return nil
//        }
//    }
//    private func getImageEntityByURL(imageURL: String) -> Tb_Image? {
//        let request: NSFetchRequest<Tb_Image> = Tb_Image.fetchRequest()
//        let predicate = NSPredicate(format: "imageUrl == %@", imageURL)
//        request.predicate = predicate
//        do {
//            return try self.mainContext.fetch(request).first
//        } catch {
//            print("Error fetching. \(error)")
//            return nil
//        }
//    }
}
