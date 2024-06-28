//
//  ExportProductsUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 28/06/2024.
//

import Foundation
import UniformTypeIdentifiers

protocol ExportProductsUseCase {
    func execute() -> URL?
}

final class ExportProductsInteractor: ExportProductsUseCase {
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func execute() -> URL? {
        let fileManager = FileManager.default
        guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        let url = libraryDirectory.appendingPathComponent("Files")
        // Verifica si la carpeta ya existe
        if !fileManager.fileExists(atPath: url.path) {
            // Crea la carpeta
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        createCSVFile(at: url)
        return url
    }

    private func createCSVFile(at url: URL) {
        let header = "Id,URL,Nombre,Precio,Costo,Activo,Cantidad,TipoUnidad\n"
        do {
            // Crear el archivo y escribir el encabezado
            try header.write(to: url, atomically: true, encoding: .utf8)
            
            // Abrir el archivo para escritura
            if let fileHandle = FileHandle(forWritingAtPath: url.path) {
                // Posicionarse al final del archivo
                fileHandle.seekToEndOfFile()
                
                // Data a escribir (simulando un gran dataset)
                var products: [Product]
                var page: Int = 1
                products = self.productRepository.getListProducts(seachText: "", primaryOrder: .nameAsc, filterAttribute: .allProducts, page: page, pageSize: 50)
                while !products.isEmpty {
                    // Escribir cada fila en el archivo
                    for product in products {
                        let line = "\(product.id),\(product.image?.imageUrl),\(product.name),\(product.unitPrice.soles),\(product.unitCost.soles),\(product.active),\(product.qty),\(product.unitType.description)\n"
                        if let rowData = line.data(using: .utf8) {
                            fileHandle.write(rowData)
                        }
                    }
                    // Agregar mas productos
                    page += 1
                    products = self.productRepository.getListProducts(seachText: "", primaryOrder: .nameAsc, filterAttribute: .allProducts, page: page, pageSize: 50)
                }
                // Cerrar el archivo
                fileHandle.closeFile()
            }
        } catch {
            print("Error al crear el archivo CSV: \(error)")
        }
    }

}
