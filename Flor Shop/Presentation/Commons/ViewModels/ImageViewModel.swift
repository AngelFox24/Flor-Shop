//
//  ImageViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/04/23.
//

import Foundation
import SwiftUI
import CoreData

class ImageViewModel: ObservableObject {
    
    @Published var image: Image?
    @Published var isLoading: Bool = false
    
    //Managers
    private let mainContext: NSManagedObjectContext
    private let imageManager: ImageManager
    //Repositories
    private let imageRepository: ImageRepositoryImpl
    //UseCases
    private let deleteUnusedImagesUseCase: DeleteUnusedImagesUseCase
    private let loadSavedImageUseCase: LoadSavedImageUseCase
    private let downloadImageUseCase: DownloadImageUseCase
    private let saveImageUseCase: SaveImageUseCase
    
    init() {
        self.mainContext = CoreDataProvider.shared.viewContext
        
        self.imageManager = LocalImageManager(mainContext: self.mainContext)
        self.imageRepository = ImageRepositoryImpl(manager: self.imageManager)
        self.deleteUnusedImagesUseCase = DeleteUnusedImagesInteractor(imageRepository: self.imageRepository)
        self.loadSavedImageUseCase = LoadSavedImageInteractor(imageRepository: self.imageRepository)
        self.downloadImageUseCase = DownloadImageInteractor(imageRepository: self.imageRepository)
        self.saveImageUseCase = SaveImageInteractor(imageRepository: self.imageRepository)
    }
    
    func loadImage(id: UUID, url: String?) async {
        print("Se intenta cargar imagen \(id)")
        //Fijarse si hay en local
        if let savedImage = self.loadSavedImageUseCase.execute(id: id) {
            await MainActor.run {
                print("Se carga imagen local")
                self.image = Image(uiImage: savedImage)
            }
        } else {
            //Sino descargar
            guard let urlNN = url, let urlT = URL(string: urlNN) else {
                return
            }
            print("Se intenta descargar imagen")
            let imageOp = await self.downloadImageUseCase.execute(url: urlT)
            //let dataOp = ImageViewModel.resizeImage(data: dataNN, maxWidth: 200, maxHeight: 200)
            if let uiImageNN = imageOp {
                await MainActor.run {
                    print("Se carga imagen descargada")
                    self.image = Image(uiImage: uiImageNN)
                }
                self.saveImageUseCase.execute(id: id, image: uiImageNN, resize: false)
            }
        }
    }
    /*
    static func resizeImage(data: Data, maxWidth: CGFloat, maxHeight: CGFloat) -> Data? {
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
     */
    /*
    func downloadImage(url: URL) async -> Data? {
        do {
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request)
            //let dataOptimized = try resizeImage(data: data, maxWidth: 200, maxHeight: 200)
            return data
        } catch {
            print("Error al descargar la imagen: \(error)")
            return nil
        }
    }
     */
    /*
    @discardableResult
    static func saveImage(id: UUID, image: UIImage, resize: Bool = true) -> String {
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
                    let dataOp = ImageViewModel.resizeImage(data: data, maxWidth: 200, maxHeight: 200)
                    if let dataOpNN = dataOp {
                        imageHash = ImageViewModel.generarHash(data: dataOpNN)
                        try dataOpNN.write(to: fileURL)
                    } else {
                        if ImageViewModel.shouldSaveImage(imageData: data) {
                            imageHash = ImageViewModel.generarHash(data: data)
                            try data.write(to: fileURL)
                        } else {
                            print("La imagen es muy grande para ser guardada")
                        }
                    }
                } else {
                    if ImageViewModel.shouldSaveImage(imageData: data) {
                        imageHash = ImageViewModel.generarHash(data: data)
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
    */
    /*
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
     */
    /*
    static func loadSavedImage(id: UUID) -> UIImage? {
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
     */
    /*
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
    static func shouldSaveImage(imageData: Data) -> Bool {
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
     */
}
