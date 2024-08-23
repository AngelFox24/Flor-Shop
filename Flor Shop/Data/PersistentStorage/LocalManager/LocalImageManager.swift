//
//  LocalImageManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 25/08/23.
//

import Foundation
import CoreData
import SwiftUI
import ImageIO
import CoreGraphics
import MobileCoreServices
import UniformTypeIdentifiers
import CommonCrypto

protocol LocalImageManager {
    func sync(imageURLsDTOs: [ImageURLDTO]) throws
    func getLastUpdated() -> Date
    func save(image: ImageUrl) throws -> ImageUrl
    func saveImage(image: UIImage) async throws -> ImageUrl
    func deleteUnusedImages() async
}

class LocalImageManagerImpl: LocalImageManager {
    let mainContext: NSManagedObjectContext
    let sessionConfig: SessionConfig
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastUpdated() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        let predicate = NSPredicate(format: "updatedAt != nil")
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let date = try self.mainContext.fetch(request).compactMap{$0.updatedAt}.first
            guard let dateNN = date else {
                return dateFrom!
            }
            return dateNN
        } catch let error {
            print("Error fetching. \(error)")
            return dateFrom!
        }
    }
    func sync(imageURLsDTOs: [ImageURLDTO]) throws {
        for imageURLDTO in imageURLsDTOs {
            if let imageEntity = self.sessionConfig.getImageEntityById(context: self.mainContext, imageId: imageURLDTO.id) { //Comprobamos si la imagen o la URL existe para asignarle el mismo
                imageEntity.imageUrl = imageURLDTO.imageUrl
                imageEntity.imageHash = imageURLDTO.imageHash
                imageEntity.createdAt = imageURLDTO.createdAt.internetDateTime()
                imageEntity.updatedAt = imageURLDTO.updatedAt.internetDateTime()
                saveData()
            } else {
                let imageEntity = Tb_ImageUrl(context: self.mainContext)
                imageEntity.idImageUrl = imageURLDTO.id
                imageEntity.imageUrl = imageURLDTO.imageUrl
                imageEntity.imageHash = imageURLDTO.imageHash
                imageEntity.createdAt = imageURLDTO.createdAt.internetDateTime()
                imageEntity.updatedAt = imageURLDTO.updatedAt.internetDateTime()
                saveData()
            }
        }
    }
    func save(image: ImageUrl) throws -> ImageUrl {
        let url = image.imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        let hash = image.imageHash.trimmingCharacters(in: .whitespacesAndNewlines)
        guard url == "" else {
            throw LocalStorageError.notFound("La URL no es valida")
        }
        if let imageEntity = getImageEntityByURL(imageURL: url) {
            imageEntity.idImageUrl = image.id
            imageEntity.imageHash = hash == "" ? imageEntity.imageHash : hash
            imageEntity.imageUrl = image.imageUrl
            imageEntity.createdAt = image.createdAt
            imageEntity.updatedAt = image.updatedAt
            saveData()
            return imageEntity.toImage()
        } else {
            let newImageEntity = Tb_ImageUrl(context: self.mainContext)
            newImageEntity.idImageUrl = image.id
            newImageEntity.imageUrl = image.imageUrl
            newImageEntity.imageHash = image.imageHash
            newImageEntity.createdAt = image.createdAt
            newImageEntity.updatedAt = image.updatedAt
            saveData()
            return newImageEntity.toImage()
        }
    }
    func saveImage(image: UIImage) async throws -> ImageUrl {
        let imageData = try await LocalImageManagerImpl.getEfficientImageTreated(image: image)
        //Obtener hash
        let imageHash = LocalImageManagerImpl.generarHash(data: imageData)
        //Buscar imagen por hash
        if let imageEntity = getImageEntityByHash(imageHash: imageHash) {
            return imageEntity.toImage()
        } else {
            //Crear nueva imagen
            let imageUrl = ImageUrl(
                id: UUID(),
                imageUrl: "",
                imageHash: imageHash,
                createdAt: Date(),
                updatedAt: Date()
            )
            //Guardar imagen en Local
            let uiImage = try LocalImageManagerImpl.getUIImage(data: imageData)
            try LocalImageManagerImpl.saveImageInLocal(id: imageUrl.id, image: uiImage)
            //Guardar Imagen en BD
            return try save(image: imageUrl)
        }
    }
    func deleteUnusedImages() async {
        async let imagesLocal = getImagesIdsLocal()
        let imagesCoreData = await getImagesIdsCoreData()
        let imagesToDelete = await imagesLocal.filter { !imagesCoreData.contains($0) }
        await deleteImageFile(imagesNames: imagesToDelete)
    }
    //MARK: Private Funtions
    private func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            rollback()
            print("Error al guardar en LocalImageManager: \(error)")
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
    private func getImageEntityByHash(imageHash: String) -> Tb_ImageUrl? {
        let request: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        let predicate = NSPredicate(format: "imageHash == %@", imageHash)
        request.predicate = predicate
        do {
            return try self.mainContext.fetch(request).first
        } catch {
            print("Error fetching. \(error)")
            return nil
        }
    }
    private func getImageEntityByURL(imageURL: String) -> Tb_ImageUrl? {
        let request: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        let predicate = NSPredicate(format: "imageUrl == %@", imageURL)
        request.predicate = predicate
        do {
            return try self.mainContext.fetch(request).first
        } catch {
            print("Error fetching. \(error)")
            return nil
        }
    }
    private func getImagesIdsCoreData() async -> [String] {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_ImageUrl")
        
        let predicate = NSPredicate(format: "idImageUrl != nil")
        fetchRequest.predicate = predicate
        
        fetchRequest.propertiesToFetch = ["idImageUrl"]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            print("Se intenta retornar la lista")
            //return try self.mainContext.fetch(fetchRequest)
            let res = try self.mainContext.fetch(fetchRequest)
            let ret = res.compactMap { value in
                guard let id = value["idImageUrl"] as? UUID else {
                    return ""
                }
                return id.uuidString
            }
            return ret.compactMap { $0.isEmpty ? nil : $0 }
        } catch {
            print("Error borrar imagenes sin uso: \(error.localizedDescription)")
            return []
        }
    }
    private func getImagesIdsLocal() async -> [String] {
        var imagesNames: [String] = []
        let fileManager = FileManager.default
        guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return []
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            for imageURL in directoryContents {
                if imageURL.pathExtension.lowercased() == "jpg" || imageURL.pathExtension.lowercased() == "jpeg" || imageURL.pathExtension.lowercased() == "png" {
                    let imagename = imageURL.deletingPathExtension()
                    imagesNames.append(imagename.lastPathComponent)
                }
            }
            return imagesNames
        } catch {
            return []
        }
    }
    private func deleteImageFile(imagesNames: [String]) async {
        let fileManager = FileManager.default
        guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            
            for imageURL in directoryContents {
                if imageURL.pathExtension.lowercased() == "jpg" || imageURL.pathExtension.lowercased() == "jpeg" || imageURL.pathExtension.lowercased() == "png" {
                    let imageRes = imageURL
                    let imageName = imageRes.deletingPathExtension()
                    let imageNameString = imageName.lastPathComponent
                    if imagesNames.contains(imageNameString) {
                        try fileManager.removeItem(at: imageRes)
                    }
                }
            }
        } catch {
            print("Error al borrar imagenes sin uso")
        }
    }
    private func shouldSaveImage(imageData: Data) -> Bool {//Talves se pueda eliminar o dejar en uses cases
        guard let uiImage = UIImage(data: imageData) else {
            return false
        }
        let imageSize = uiImage.size
        let imageSizeInPixels = Int(imageSize.width) * Int(imageSize.height)
        let imageSizeInKB = imageData.count / 1024 // Divide entre 1024 para obtener el tamaño en KB
        let maximumImageSizeInPixels = 1920 * 1080 // Define el tamaño máximo permitido en píxeles
        let maximumImageSizeInKB = 1024 // Define el tamaño máximo permitido en KB
        if imageSizeInPixels > maximumImageSizeInPixels || imageSizeInKB > maximumImageSizeInKB {
            return false
        }
        print("La imagen es valida para ser guardada \(imageSizeInPixels.description) ----- \(imageSizeInKB.description)")
        return true
    }
    //MARK: Static Funtions
    static func loadImage(image: ImageUrl) async throws -> UIImage {
        if let savedImage = LocalImageManagerImpl.loadSavedImage(id: image.id) {
            return try LocalImageManagerImpl.getUIImage(data: savedImage)
        } else {
            guard let url = URL(string: image.imageUrl) else {
                throw LocalStorageError.notFound("No se pudo crear la url")
            }
            let imageDataTreated = try await LocalImageManagerImpl.getEfficientImageTreated(url: url)
            let uiImageTreated = try LocalImageManagerImpl.getUIImage(data: imageDataTreated)
            do {
                try LocalImageManagerImpl.saveImageInLocal(id: image.id, image: uiImageTreated)
            } catch {
                print("No se pudo guardar la imagen: \(error)")
            }
            return uiImageTreated
        }
    }
    static func getUIImage(data: Data) throws -> UIImage {
        guard let uiImage = UIImage(data: data) else {
            throw LocalStorageError.notFound("No se puede convertir de Data a UIImage")
        }
        return uiImage
    }
    static func getImageData(uiImage: UIImage) throws -> Data {
        guard let imageData = uiImage.jpegData(compressionQuality: 1.0) else {
            throw LocalStorageError.notFound("No se puede convertir de Data a UIImage")
        }
        return imageData
    }
    static func getEfficientImageTreated(image: UIImage) async throws -> Data {
        let originalImageData = try LocalImageManagerImpl.getImageData(uiImage: image)
        //Extraer la orientacion
        let orientation = try LocalImageManagerImpl.extractOrientation(from: originalImageData)
        print("Orientacion: \(orientation)")
        //Hacerlo eficiente
        let imagen = try await LocalImageManagerImpl.getEfficientImage(uiImage: image)
        var imageData = try LocalImageManagerImpl.getImageData(uiImage: imagen)
        //Asignar la orientacion original
        try LocalImageManagerImpl.editOrientation(imageData: &imageData, newOrientation: orientation)
        print("Se aplico orientacion")
        //Guardar imagen en Local
        return imageData
    }
//    static func getImageData(url: URL) async throws -> Data {
//        //Descargar de internet
//        let imageData = try await LocalImageManagerImpl.downloadImage(url: url)
//        //Tratar la imagen
//        let uiImage = try LocalImageManagerImpl.getUIImage(data: imageData)
//        let imageDataTreated = try await LocalImageManagerImpl.getEfficientImageTreated(image: uiImage)
//        let uiImageTreated = try LocalImageManagerImpl.getUIImage(data: imageDataTreated)
//        return uiImageTreated
//    }
    static func getEfficientImageTreated(url: URL) async throws -> Data {
        //        //Descargar de internet
        let imageData = try await LocalImageManagerImpl.downloadImage(url: url)
        let uiImage = try LocalImageManagerImpl.getUIImage(data: imageData)
        let imageDataTreated = try await LocalImageManagerImpl.getEfficientImageTreated(image: uiImage)
        return imageDataTreated
    }
    static private func getEfficientImage(uiImage: UIImage) async throws -> UIImage {
        var imageData = try LocalImageManagerImpl.getImageData(uiImage: uiImage)
        //Redimensionar
        try LocalImageManagerImpl.resizeImage(data: &imageData, maxWidth: 200, maxHeight: 200)
        return try LocalImageManagerImpl.getUIImage(data: imageData)
    }
    static func generarHash(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        let hashData = Data(hash)
        let hashString = hashData.map { String(format: "%02hhx", $0) }.joined()
        print("Se genero hash: \(hashString)")
        return hashString
    }
    //MARK: Static Private Funtions
    static private func saveImageInLocal(id: UUID, image: UIImage) throws {
        //Validar antes de guardar que la imagen no sea muy grande
        //Tamaño maximo permitido es 1920x1080
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            throw LocalStorageError.notFound("No se puedo obtener el directorio de imagenes")
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        do {
            try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error al crear el directorio de imágenes: \(error)")
            throw LocalStorageError.notFound("Error al crear el directorio de imágenes: \(error)")
        }
        let fileURL = imagesDirectory.appendingPathComponent(id.uuidString + ".jpeg")
        let data = try LocalImageManagerImpl.getImageData(uiImage: image)
        do {
            print("Se guardo la imagen correctamente")
            try data.write(to: fileURL)
            return
        } catch {
            print("Error al guardar la imagen: \(error)")
            throw LocalStorageError.notFound("Error al guardar la imagen: \(error)")
        }
    }
    static private func editOrientation(imageData: inout Data, newOrientation: Int) throws {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let sourceType = CGImageSourceGetType(source),
              let mutableData = CFDataCreateMutableCopy(nil, 0, imageData as CFData),
              let destination = CGImageDestinationCreateWithData(mutableData, sourceType, 1, nil) else {
            throw LocalStorageError.notFound("No se puede obtener CGImageDestination en editOrientation")
        }
        
        let options = [kCGImagePropertyOrientation: NSNumber(value: newOrientation)]
        
        CGImageDestinationAddImageFromSource(destination, source, 0, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        imageData = mutableData as Data
    }
    static private func extractOrientation(from imageData: Data) throws -> Int {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let metaData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let tiffData = metaData[kCGImagePropertyTIFFDictionary as String] as? [String: Any],
              let orientation = tiffData[kCGImagePropertyTIFFOrientation as String] as? Int else {
            throw LocalStorageError.notFound("No se puede extraer la orientacion")
        }
        return orientation
    }
    static private func resizeImage(data: inout Data, maxWidth: CGFloat, maxHeight: CGFloat) throws {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw LocalStorageError.notFound("No se puede convertir Data a Image")
        }
        
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        
        var newSize = CGSize(width: width, height: height)
        
        if width > maxWidth || height > maxHeight {
            let aspectRatio = width / height
            if width > height {
                newSize.width = maxWidth
                newSize.height = maxWidth / aspectRatio
            } else {
                newSize.height = maxHeight
                newSize.width = maxHeight * aspectRatio
            }
        } else {
            return
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil, width: Int(newSize.width), height: Int(newSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            throw LocalStorageError.notFound("No se puede crear CGContext")
        }
        
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(origin: .zero, size: newSize))
        
        guard let newImage = context.makeImage() else {
            throw LocalStorageError.notFound("No se puede crear CGImage")
        }
        
        let resizedImageData = CFDataCreateMutable(nil, 0)
        guard let resizedData = resizedImageData else {
            throw LocalStorageError.notFound("No se puede crear CFMutableData")
        }
        let dest = CGImageDestinationCreateWithData(resizedData, UTType.jpeg.identifier as CFString, 1, nil)
        guard let destination = dest else {
            throw LocalStorageError.notFound("No se puede crear CGImageDestination")
        }
        // Configurar opciones para eliminar los metadatos
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 0.7, kCGImageDestinationMetadata: true]
        CGImageDestinationAddImage(destination, newImage, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        data = resizedData as Data
    }
    static private func loadSavedImage(id: UUID) -> Data? {
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return nil
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        let fileURL = imagesDirectory.appendingPathComponent(id.uuidString + ".jpeg")
        if let imageData = try? Data(contentsOf: fileURL) {
            print("Se carga desde local: \(fileURL.path)")
            return imageData
        } else {
            print("No se pudo obtener la imagen \(id.uuidString).jpeg")
            return nil
        }
    }
    static private func downloadImage(url: URL) async throws -> Data {
        do {
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request)
            return data
        } catch {
            throw LocalStorageError.notFound("Error al descargar la imagen: \(error)")
        }
    }
    static private func extractMetadata(from imageData: Data) -> [CFString: Any]? {
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        guard let imageData = image.jpegData(compressionQuality: 1.0) as CFData?,
              let source = CGImageSourceCreateWithData(imageData, nil) else {
            return nil
        }

        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            return nil
        }
        return properties
    }
    
}
