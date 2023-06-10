//
//  ImageProductNetworkViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/04/23.
//

import Foundation
import SwiftUI
import Combine

class ImageProductNetworkViewModel: ObservableObject {
    
    @Published var imageProduct: Image?
    //Image("ProductoSinNombre")
    var suscriber = Set<AnyCancellable>()
    
    func getImage(id: UUID , url: URL){
        if let savedImage = loadSavedImage(id: id) {
            imageProduct = Image(uiImage: savedImage)
        }else {
            /*URLSession.shared.dataTaskPublisher(for: url)
             .map(\.data)
             .compactMap{UIImage(data: $0)}
             .map{Image(uiImage: $0)}
             .replaceEmpty(with: Image("ProductoSinNombre"))
             .replaceError(with: Image("ProductoSinNombre"))
             .receive(on: DispatchQueue.main) //Regresamos al hilo principal, es una buena practica de Swift
             .sink(receiveCompletion: { completion in
             switch completion {
             case .finished:
             break
             case .failure(let error):
             print("Error al descargar la imagen: \(error)")
             }
             }, receiveValue: { image in
             self.imageProduct = image
             saveImage(id: id, image: image)
             })
             .assign(to: \.imageProduct,on: self) //Aqui asignamos luego de validar
             .store(in: &suscriber)
             */
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { data, response in
                    guard let image = UIImage(data: data) else {
                        throw URLError(.badServerResponse)
                    }
                    return image
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error al descargar la imagen: \(error)")
                    }
                }, receiveValue: { image in
                    self.imageProduct = Image(uiImage: image)
                    if self.shouldSaveImage(image: image){
                        self.saveImage(id: id, image: image)
                    }
                })
                .store(in: &suscriber)
        }
    }
    
    func saveImage(id: UUID, image: UIImage) {
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        
        do {
            try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error al crear el directorio de imágenes: \(error)")
            return
        }
        
        let fileURL = imagesDirectory.appendingPathComponent(id.uuidString + ".jpg")
        
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
                print ("Se guardo en el dispositivo local \(id.uuidString)")
                print("Ruta de la imagen guardada: \(fileURL.path)")
            } catch {
                print("Error al guardar la imagen: \(error)")
            }
        }
    }
    
    func loadSavedImage(id: UUID) -> UIImage? {
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        let fileURL = imagesDirectory.appendingPathComponent(id.uuidString + ".jpg")
        
        if let imageData = try? Data(contentsOf: fileURL) {
            print ("Se obtuvo la imgen desde el dispositivo \(id.uuidString)")
            print("Ruta de la imagen guardada: \(fileURL.path)")
            return UIImage(data: imageData)
        }
        
        return nil
    }
    
    func shouldSaveImage(image: UIImage) -> Bool {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return false
        }
        
        let imageSize = image.size
        let imageSizeInPixels = Int(imageSize.width) * Int(imageSize.height)
        let imageSizeInKB = imageData.count / 1024 // Divide entre 1024 para obtener el tamaño en KB
        
        let maximumImageSizeInPixels = 1920 * 1080 // Define el tamaño máximo permitido en píxeles
        let maximumImageSizeInKB = 1024 // Define el tamaño máximo permitido en KB
        
        if imageSizeInPixels > maximumImageSizeInPixels || imageSizeInKB > maximumImageSizeInKB {
            return false
        }
        print ("La imagen es valida para ser guardada \(imageSizeInPixels.description) ----- \(imageSizeInKB.description)")
        return true
    }
}
