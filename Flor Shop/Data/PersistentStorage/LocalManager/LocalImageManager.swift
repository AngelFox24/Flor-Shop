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
    func deleteUnusedImages() async
    func loadSavedImage(id: UUID) -> UIImage?
    func downloadImage(url: URL) async -> UIImage?
    func save(idImage: UUID, image: UIImage) -> ImageUrl?
    func save(image: ImageUrl) throws -> ImageUrl
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
    func deleteUnusedImages() async {
        async let imagesLocal = getImagesIdsLocal()
        let imagesCoreData = await getImagesIdsCoreData()
        let imagesToDelete = await imagesLocal.filter { !imagesCoreData.contains($0) }
        await deleteImageFile(imagesNames: imagesToDelete)
    }
    func loadSavedImage(id: UUID) -> UIImage? {
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return nil
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        let fileURL = imagesDirectory.appendingPathComponent(id.uuidString + ".jpeg")
        if let imageData = try? Data(contentsOf: fileURL) {
            print("Ruta de la imagen guardada: \(fileURL.path)")
            print("Se carga desde local")
            return UIImage(data: imageData)
        } else {
            print("No se pudo obtener la imagen \(id.uuidString).jpeg")
        }
        return nil
    }
    func save(image: ImageUrl) throws -> ImageUrl {
        let url = image.imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        let hash = image.imageHash.trimmingCharacters(in: .whitespacesAndNewlines)
        guard url == "" else {
            throw LocalStorageError.notFound("La URL no es valida")
        }
        if let imageEntity = getImageEntityByURL(imageURL: url) {
            imageEntity.idImageUrl = image.id
            imageEntity.imageHash = image.imageHash == "" ? imageEntity.imageHash : image.imageHash
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
    @discardableResult
    func save(idImage: UUID, image: UIImage) -> ImageUrl? {
        //Recortar a tamaño deseado
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        guard let imageDataResized = resizeImage(data: imageData, maxWidth: 200, maxHeight: 200) else {
            return nil
        }
        //Obtener Hash
        let imageHash = generarHash(data: imageDataResized)
        //Validar si existe otra imagen igual
        guard let imageEntity = getImageEntityByHash(imageHash: imageHash) else {
            //Se guarda como nueva imagen
            guard let uiImage = UIImage(data: imageDataResized) else {
                return nil
            }
            if saveImageInLocal(id: idImage, image: uiImage) {
                return ImageUrl(
                    id: idImage,
                    imageUrl: "",
                    imageHash: imageHash,
                    createdAt: Date(),
                    updatedAt: Date()
                )
            } else {
                return nil
            }
        }
        return imageEntity.toImage()
    }
    func downloadImage(url: URL) async -> UIImage? {
        do {
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request)
            let dataOptimized = resizeImage(data: data, maxWidth: 200, maxHeight: 200)
            guard let dataOp = dataOptimized else {
                return nil
            }
            return UIImage(data: dataOp)
        } catch {
            print("Error al descargar la imagen: \(error)")
            return nil
        }
    }
    func extractMetadata(from imageData: Data) -> [CFString: Any]? {
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
        print("Properties: \(properties)")
        return properties
    }
    func saveImage(id: UUID, image: UIImage, resize: Bool = true) -> String {
        var imageHash = ""
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return imageHash
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        do {
            try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error al crear el directorio de imágenes: \(error)")
            return imageHash
        }
        let fileURL = imagesDirectory.appendingPathComponent(id.uuidString + ".jpeg")
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                if resize {
                    let dataOp = resizeImage(data: data, maxWidth: 200, maxHeight: 200)
                    if var dataOpNN = dataOp {
                        imageHash = generarHash(data: dataOpNN)
                        if let originalOrientationNN = extractOrientation(from: data) {
                            editOrientation(imageData: &dataOpNN, newOrientation: originalOrientationNN)
                        }
                        try dataOpNN.write(to: fileURL)
                    } else {
                        if shouldSaveImage(imageData: data) {
                            imageHash = generarHash(data: data)
                            print("Se guarda en local sin optimizar")
                            try data.write(to: fileURL)
                        } else {
                            print("La imagen es muy grande para ser guardada")
                        }
                    }
                } else {
                    if shouldSaveImage(imageData: data) {
                        imageHash = generarHash(data: data)
                        print("Se guarda en local sin optimizar")
                        try data.write(to: fileURL)
                    } else {
                        print("La imagen es muy grande para ser guardada")
                    }
                }
                print("Se guardo la imagen correctamente")
            } catch {
                print("Error al guardar la imagen: \(error)")
            }
        }
        return imageHash
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
    private func shouldSaveImage(imageData: Data) -> Bool {
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
    private func generarHash(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        let hashData = Data(hash)
        let hashString = hashData.map { String(format: "%02hhx", $0) }.joined()
        print("Se genero hash: \(hashString)")
        return hashString
    }
    private func saveImageInLocal(id: UUID, image: UIImage) -> Bool {
        //Validar antes de guardar que la imagen no sea muy grande
        //Tamaño maximo permitido es 1920x1080
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return false
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        do {
            try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error al crear el directorio de imágenes: \(error)")
            return false
        }
        let fileURL = imagesDirectory.appendingPathComponent(id.uuidString + ".jpeg")
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                //Validar antes de guardar que la imagen no sea muy grande
                if shouldSaveImage(imageData: data) {
                    print("Se guardo la imagen correctamente")
                    try data.write(to: fileURL)
                    return true
                } else {
                    print("La imagen es muy grande para ser guardada")
                    return false
                }
            } catch {
                print("Error al guardar la imagen: \(error)")
                return false
            }
        } else {
            return false
        }
    }
    // Función para editar la orientación de una imagen en los metadatos Exif
    private func editOrientation(imageData: inout Data, newOrientation: Int) {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let sourceType = CGImageSourceGetType(source),
              let mutableData = CFDataCreateMutableCopy(nil, 0, imageData as CFData),
              let destination = CGImageDestinationCreateWithData(mutableData, sourceType, 1, nil) else {
            return
        }
        
        let options = [kCGImagePropertyOrientation: NSNumber(value: newOrientation)]
        
        CGImageDestinationAddImageFromSource(destination, source, 0, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        imageData = mutableData as Data
    }
    private func extractOrientation(from imageData: Data) -> Int? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let metaData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let tiffData = metaData[kCGImagePropertyTIFFDictionary as String] as? [String: Any],
              let orientation = tiffData[kCGImagePropertyTIFFOrientation as String] as? Int else {
            return nil
        }
        return orientation
    }
    private func resizeImage(data: Data, maxWidth: CGFloat, maxHeight: CGFloat) -> Data? {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return nil
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
            return data
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil, width: Int(newSize.width), height: Int(newSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(origin: .zero, size: newSize))
        
        guard let newImage = context.makeImage() else {
            return nil
        }
        
        let resizedImageData = CFDataCreateMutable(nil, 0)
        guard let resizedData = resizedImageData else { return nil }
        let dest = CGImageDestinationCreateWithData(resizedData, UTType.jpeg.identifier as CFString, 1, nil)
        guard let destination = dest else { return nil }
        // Configurar opciones para eliminar los metadatos
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 0.7, kCGImageDestinationMetadata: true]
        CGImageDestinationAddImage(destination, newImage, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        return resizedData as Data
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
}
