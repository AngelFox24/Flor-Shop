//
//  ExportProductsUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 28/06/2024.
//

import Foundation
import UniformTypeIdentifiers

protocol ExportProductsUseCase {
    func execute(url: URL)
}

final class ExportProductsInteractor: ExportProductsUseCase {
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func execute(url: URL) {
        print("Creando CSV")
        createCSVFile(at: url)
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
                print("Reciviendo primer lote: \(products.count)")
                while !products.isEmpty {
                    print("Iterando")
                    // Escribir cada fila en el archivo
                    for product in products {
                        var idProduct = product.id.description
                        var imageURL: String = product.image?.imageUrl ?? ""
                        imageURL = imageURL.replacingOccurrences(of: "\\r\\n|\\n|\\r", with: "", options: .regularExpression)
                        imageURL = imageURL.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
                        imageURL = imageURL.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
                        imageURL = "\"" + imageURL + "\""
                        let nombre = "\"" + product.name + "\""
                        let precio = product.unitPrice.soles
                        let costo = product.unitCost.soles
                        let activo = product.active
                        let cantidad = product.qty
                        let tipoUnidad = product.unitType.description
                        let line = "\(idProduct),\(imageURL),\(nombre),\(precio),\(costo),\(activo),\(cantidad),\(tipoUnidad)\n"
                        if let rowData = line.data(using: .utf8) {
                            fileHandle.write(rowData)
                        }
                    }
                    // Agregar mas productos
                    page += 1
                    products = self.productRepository.getListProducts(seachText: "", primaryOrder: .nameAsc, filterAttribute: .allProducts, page: page, pageSize: 50)
                }
                // Cerrar el archivo
                print("Cerrando Archivo")
                fileHandle.closeFile()
            }
        } catch {
            print("Error al crear el archivo CSV: \(error)")
        }
    }

}
