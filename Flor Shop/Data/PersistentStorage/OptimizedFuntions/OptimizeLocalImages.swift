//
//  OptimizeLocalImages.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 1/04/24.
//

import Foundation
import CoreGraphics
import ImageIO
import MobileCoreServices
import UniformTypeIdentifiers

// Función asíncrona para redimensionar imágenes manteniendo la proporción
func resizeImagesInDefaultDirectory(maxWidth: CGFloat, maxHeight: CGFloat) async throws {
    let fileManager = FileManager.default
    guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
        return
    }
    let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
    let directoryContents = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
    
    for imageURL in directoryContents {
        if imageURL.pathExtension.lowercased() == "jpg" || imageURL.pathExtension.lowercased() == "jpeg" || imageURL.pathExtension.lowercased() == "png" {
            // Procesar solo archivos de imagen
            do {
                let imageData = try Data(contentsOf: imageURL)
                // Redimensionar la imagen manteniendo la proporción
                guard let resizedImageData = try resizeImage(data: imageData, maxWidth: maxWidth, maxHeight: maxHeight) else {
                    print("No se pudo redimensionar la imagen.")
                    continue
                }
                
                // Guardar la imagen redimensionada, reemplazando la original
                try resizedImageData.write(to: imageURL, options: .atomic)
                print("Imagen redimensionada y reemplazada en: \(imageURL)")
            } catch {
                print("Error al procesar la imagen: \(error)")
            }
        }
    }
}

// Función para redimensionar una imagen manteniendo la proporción
func resizeImage(data: Data, maxWidth: CGFloat, maxHeight: CGFloat) throws -> Data? {
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

// Uso de la función para redimensionar imágenes en el directorio por defecto
/*
Task {
    do {
        try await resizeImagesInDefaultDirectory(maxWidth: 200, maxHeight: 200)
    } catch {
        print("Error al redimensionar las imágenes: \(error)")
    }
}
*/
