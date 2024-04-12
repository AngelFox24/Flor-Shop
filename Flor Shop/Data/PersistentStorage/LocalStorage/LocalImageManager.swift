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

protocol ImageManager {
    func deleteUnusedImages() async
    func loadSavedImage(id: UUID) -> UIImage?
    func downloadImage(url: URL) async -> UIImage?
    func saveImage(id: UUID, image: UIImage, resize: Bool) -> String
}

class LocalImageManager: ImageManager {
    let mainContext: NSManagedObjectContext
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalImageManager: \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    func deleteUnusedImages() async {
        async let imagesLocal = getImagesIdsLocal()
        let imagesCoreData = await getImagesIdsCoreData()
        let imagesToDelete = await imagesLocal.filter { !imagesCoreData.contains($0) }
        await deleteImageFile(imagesNames: imagesToDelete)
    }
    func deleteImageFile(imagesNames: [String]) async {
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
    func getImagesIdsLocal() async -> [String] {
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
    func getImagesIdsCoreData() async -> [String] {
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
    func loadSavedImage(id: UUID) -> UIImage? {
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return nil
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        let fileURL = imagesDirectory.appendingPathComponent(id.uuidString + ".jpeg")
        if let imageData = try? Data(contentsOf: fileURL) {
            print("Ruta de la imagen guardada: \(fileURL.path)")
            return UIImage(data: imageData)
        } else {
            print("No se pudo obtener la imagen \(id.uuidString).jpeg")
        }
        return nil
    }
    func downloadImage(url: URL) async -> UIImage? {
        do {
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request)
            let dataOptimized = try resizeImage(data: data, maxWidth: 200, maxHeight: 200)
            guard let dataOp = dataOptimized else {
                return nil
            }
            return UIImage(data: dataOp)
        } catch {
            print("Error al descargar la imagen: \(error)")
            return nil
        }
    }
    func resizeImage(data: Data, maxWidth: CGFloat, maxHeight: CGFloat) -> Data? {
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
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 0.7, kCGImageDestinationMetadata: false]
        CGImageDestinationAddImage(destination, newImage, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        return resizedData as Data
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
                    if let dataOpNN = dataOp {
                        imageHash = generarHash(data: dataOpNN)
                        try dataOpNN.write(to: fileURL)
                    } else {
                        if shouldSaveImage(imageData: data) {
                            imageHash = generarHash(data: data)
                            try data.write(to: fileURL)
                        } else {
                            print("La imagen es muy grande para ser guardada")
                        }
                    }
                } else {
                    if shouldSaveImage(imageData: data) {
                        imageHash = generarHash(data: data)
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
    func generarHash(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        let hashData = Data(hash)
        let hashString = hashData.map { String(format: "%02hhx", $0) }.joined()
        print("Se genero hash: \(hashString)")
        return hashString
    }
    func deleteImage(id: UUID) {
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        let fileURL = imagesDirectory.appendingPathComponent(id.uuidString + ".jpeg")
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Se eliminó la imagen con el ID \(id.uuidString)")
        } catch {
            print("Error al eliminar la imagen con el ID \(id.uuidString): \(error.localizedDescription)")
        }
    }
    func shouldSaveImage(imageData: Data) -> Bool {
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
}
