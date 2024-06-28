//
//  ExportProductsUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 28/06/2024.
//

import Foundation

protocol ExportProductsUseCase {
    func execute(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) -> [Product]
}

final class ExportProductsInteractor: ExportProductsUseCase {
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func execute(seachText: String, primaryOrder: PrimaryOrder, filterAttribute: ProductsFilterAttributes, page: Int) -> [Product] {
        let url = URL(string: "sda")
        createCSVFile(at: url)
        guard page >= 1 else { return [] }
        return self.productRepository.getListProducts(seachText: seachText, primaryOrder: primaryOrder, filterAttribute: filterAttribute, page: page, pageSize: 15)
    }

    private func createCSVFile(at url: URL) {
        let header = "Nombre,Edad,País\n"
        do {
            // Crear el archivo y escribir el encabezado
            try header.write(to: url, atomically: true, encoding: .utf8)
            
            // Abrir el archivo para escritura
            if let fileHandle = FileHandle(forWritingAtPath: url.path) {
                // Posicionarse al final del archivo
                fileHandle.seekToEndOfFile()
                
                // Data a escribir (simulando un gran dataset)
                let data = [
                    ["Juan", "25", "España"],
                    ["Ana", "30", "México"],
                    ["Luis", "28", "Argentina"]
                ]
                
                // Escribir cada fila en el archivo
                for row in data {
                    let rowString = "\(row[0]),\(row[1]),\(row[2])\n"
                    if let rowData = rowString.data(using: .utf8) {
                        fileHandle.write(rowData)
                    }
                }
                
                // Cerrar el archivo
                fileHandle.closeFile()
            }
        } catch {
            print("Error al crear el archivo CSV: \(error)")
        }
    }

}
