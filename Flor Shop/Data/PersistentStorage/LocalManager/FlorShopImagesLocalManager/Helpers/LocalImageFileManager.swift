import Foundation
import UniformTypeIdentifiers
import UIKit
import FlorShopDTOs
import CommonCrypto

protocol LocalImageFileManager {
    func getImage(hash: String) throws -> UIImage?
    func getEfficientImage(uiImage: UIImage) throws -> UIImage
    func generarHash(uiImage: UIImage) throws -> String
    func saveImage(uiImage: UIImage, hash: String) throws -> URL //URL is a file path
    func deleteImageFile(hash: String)
}

struct LocalImageFileManagerImpl: LocalImageFileManager {
    //MARK: Main Function
    func getImage(hash: String) throws -> UIImage? {
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return nil
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        let fileURL = imagesDirectory.appendingPathComponent(hash + ".jpeg")
        if let imageData = try? Data(contentsOf: fileURL) {
            print("Se carga desde local: \(fileURL.path)")
            let uiImage = try self.getUIImage(data: imageData)
            return uiImage
        } else {
            print("No se pudo obtener la imagen \(hash).jpeg")
            return nil
        }
    }
    func generarHash(uiImage: UIImage) throws -> String {
        let data = try self.getImageData(uiImage: uiImage)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        let hashData = Data(hash)
        let hashString = hashData.map { String(format: "%02hhx", $0) }.joined()
        print("Se genero hash: \(hashString)")
        return hashString
    }
    func saveImage(uiImage: UIImage, hash: String) throws -> URL {
        let imageData = try self.getImageData(uiImage: uiImage)
        return try self.saveImageInLocal(data: imageData, hash: hash)
    }
    func deleteImageFile(hash: String) {
        let fileManager = FileManager.default
        guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        // Extensiones soportadas
        let extensions = ["jpg", "jpeg", "png"]
        for ext in extensions {
            let fileURL = imagesDirectory.appendingPathComponent("\(hash).\(ext)")
            if fileManager.fileExists(atPath: fileURL.path) {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    func getEfficientImage(uiImage: UIImage) throws -> UIImage {
        let imageData = try self.getEfficientImageTreated(image: uiImage)
        return try self.getUIImage(data: imageData)
    }
    //MARK: Private Function
    func saveImageInLocal(data: Data, hash: String) throws -> URL {
        //Validar antes de guardar que la imagen no sea muy grande
        //Tamaño maximo permitido es 1920x1080
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            throw LocalStorageError.fileSaveFailed("No se puedo obtener el directorio de imagenes")
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        do {
            try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error al crear el directorio de imágenes: \(error)")
            throw LocalStorageError.fileSaveFailed("Error al crear el directorio de imágenes: \(error)")
        }
        let fileURL = imagesDirectory.appendingPathComponent(hash + ".jpeg")
        do {
            print("Se guardo la imagen correctamente")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error al guardar la imagen: \(error)")
            throw LocalStorageError.fileSaveFailed("Error al guardar la imagen: \(error)")
        }
    }
    func getUIImage(data: Data) throws -> UIImage {
        guard let uiImage = UIImage(data: data) else {
            throw LocalStorageError.invalidInput("No se puede convertir de Data a UIImage")
        }
        return uiImage
    }
    func getImageData(uiImage: UIImage) throws -> Data {
        guard let imageData = uiImage.jpegData(compressionQuality: 1.0) else {
            throw LocalStorageError.invalidInput("No se puede convertir de Data a UIImage")
        }
        return imageData
    }
    private func getEfficientImageTreated(image: UIImage) throws -> Data {
        var imageData = try self.getImageData(uiImage: image)
        //Extraer la orientacion
        let orientation = try self.extractOrientation(from: imageData)
        print("Orientacion: \(orientation)")
        //Hacerlo eficiente
        try self.resizeImage(data: &imageData, maxWidth: 200, maxHeight: 200)
        //Asignar la orientacion original
        try self.editOrientation(imageData: &imageData, newOrientation: orientation)
        print("Se aplico orientacion")
        return imageData
    }
    private func editOrientation(imageData: inout Data, newOrientation: Int) throws {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let sourceType = CGImageSourceGetType(source),
              let mutableData = CFDataCreateMutableCopy(nil, 0, imageData as CFData),
              let destination = CGImageDestinationCreateWithData(mutableData, sourceType, 1, nil) else {
            throw LocalStorageError.fileSaveFailed("No se puede obtener CGImageDestination en editOrientation")
        }
        
        let options = [kCGImagePropertyOrientation: NSNumber(value: newOrientation)]
        
        CGImageDestinationAddImageFromSource(destination, source, 0, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        imageData = mutableData as Data
    }
    private func extractOrientation(from imageData: Data) throws -> Int {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let metaData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let tiffData = metaData[kCGImagePropertyTIFFDictionary as String] as? [String: Any],
              let orientation = tiffData[kCGImagePropertyTIFFOrientation as String] as? Int else {
            throw LocalStorageError.fileSaveFailed("No se puede extraer la orientacion")
        }
        return orientation
    }
    private func resizeImage(data: inout Data, maxWidth: CGFloat, maxHeight: CGFloat) throws {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw LocalStorageError.fileSaveFailed("No se puede convertir Data a Image")
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
            throw LocalStorageError.fileSaveFailed("No se puede crear CGContext")
        }
        
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(origin: .zero, size: newSize))
        
        guard let newImage = context.makeImage() else {
            throw LocalStorageError.fileSaveFailed("No se puede crear CGImage")
        }
        
        let resizedImageData = CFDataCreateMutable(nil, 0)
        guard let resizedData = resizedImageData else {
            throw LocalStorageError.fileSaveFailed("No se puede crear CFMutableData")
        }
        let dest = CGImageDestinationCreateWithData(resizedData, UTType.jpeg.identifier as CFString, 1, nil)
        guard let destination = dest else {
            throw LocalStorageError.fileSaveFailed("No se puede crear CGImageDestination")
        }
        // Configurar opciones para eliminar los metadatos
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 0.7, kCGImageDestinationMetadata: true]
        CGImageDestinationAddImage(destination, newImage, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        data = resizedData as Data
    }
    private func extractMetadata(from imageData: Data) -> [CFString: Any]? {
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
