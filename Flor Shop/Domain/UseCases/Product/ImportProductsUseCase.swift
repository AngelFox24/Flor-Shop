//
//  ImportProductsUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 25/08/2024.
//

import Foundation
import UniformTypeIdentifiers

protocol ImportProductsUseCase {
    func execute(url: URL) async
}

final class ImportProductsInteractor: ImportProductsUseCase {
    private let imageRepository: ImageRepository
    private let productRepository: ProductRepository
    
    init(
        imageRepository: ImageRepository,
        productRepository: ProductRepository
    ) {
        self.imageRepository = imageRepository
        self.productRepository = productRepository
    }
    
    func execute(url: URL) async {
        print("Importando CSV")
        await loadTestData(url: url)
    }
    private func loadTestData(url: URL) async {
        do {
            let urlLocalFile = try copyFileToLocalFolder(url: url)
            defer {
                do {
                    try deleteLocalFile(url: urlLocalFile)
                } catch {
                    print("Defered can't delete file")
                }
            }
            var lineCount = 0
            var countSucc: Int = 0
            var countFail: Int = 0
            for try await line in urlLocalFile.lines {
                lineCount += 1
                guard lineCount > 1 else { continue }
                let elements = line.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                if elements.count != 3 {
                    print("To much elements: \(elements.count), line: \(lineCount)")
                    countFail = countFail + 1
                    continue
                }
                let date = Date()
                let unitType = getTreatedUnitType(elements[2])
                let quantity = getTreatedQuantity(quantity: elements[2], unitType: unitType)
                let imageUrl = ImageUrl(
                    id: UUID(),
                    imageUrl: elements[0],
                    imageHash: "",
                    createdAt: date,
                    updatedAt: date
                )
                var product = Product(
                    id: UUID(),
                    active: true,
                    name: elements[1],
                    qty: quantity,
                    unitType: unitType,
                    unitCost: getTreatedAmount(elements[2]),
                    unitPrice: getTreatedAmount(elements[2]),
                    expirationDate: nil,
                    image: imageUrl,
                    createdAt: date,
                    updatedAt: date
                )
                do {
                    let newImage = try await imageRepository.save(image: imageUrl)
                    product.image = newImage
                    try await productRepository.save(product: product)
                    countSucc += 1
                } catch {
                    countFail += 1
                }
            }
            print("Total: \(countSucc + countFail), Success: \(countSucc), Fails: \(countFail), lines: \(lineCount)")
        } catch {
            print("Error al leer el archivo: \(error)")
        }
    }
    private func deleteLocalFile(url: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path(percentEncoded: false)) {
            // Si existe, eliminar el archivo actual
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Error al eliminar el archivo: \(error)")
                throw LocalStorageError.fileSaveFailed("Error al guardar el archivo: \(error)")
            }
        }
    }
    private func copyFileToLocalFolder(url: URL) throws -> URL {
        guard url.startAccessingSecurityScopedResource() else {
            throw LocalStorageError.fileSaveFailed("No se puede acceder al archivo de forma segura")
        }
        let fileManager = FileManager.default
        guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            throw LocalStorageError.fileSaveFailed("No se puedo obtener el directorio de Files")
        }
        let fileName = url.lastPathComponent + url.pathExtension
        let fileDirectory = libraryDirectory.appendingPathComponent("Files")
        do {
            try FileManager.default.createDirectory(at: fileDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error al crear el directorio de Files: \(error)")
            throw LocalStorageError.fileSaveFailed("Error al crear el directorio de Files: \(error)")
        }
        let fileURL = fileDirectory.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            // Si existe, eliminar el archivo actual
            try deleteLocalFile(url: fileURL)
        }
        do {
            // Copiar el archivo desde la URL de origen a la de destino
            try fileManager.copyItem(at: url, to: fileURL)
            return fileURL
        } catch {
            print("Error al guardar el archivo: \(error)")
            throw LocalStorageError.fileSaveFailed("Error al guardar el archivo: \(error)")
        }
    }
    private func getTreatedUnitType(_ input: String) -> UnitTypeEnum {
        var unitType = UnitTypeEnum.unit
        for type in UnitTypeEnum.allValues {
            if type.description.lowercased() == input.lowercased() {
                unitType = type
            }
        }
        return unitType
    }
    private func getTreatedQuantity(quantity: String, unitType: UnitTypeEnum) -> Int {
        var quantityString = quantity
        switch unitType {
        case .unit:
            quantityString = quantityString.replacingOccurrences(of: ",", with: "")
            if quantityString.contains(".") {
                quantityString = quantityString.replacingOccurrences(of: ".", with: "")
            }
        case .kilo:
            quantityString = quantityString.replacingOccurrences(of: ",", with: "")
            if quantityString.contains(".") {
                quantityString = quantityString.replacingOccurrences(of: ".", with: "")
            } else {
                quantityString += "000"
            }
        }
        guard let quantityTreated = Int(quantityString) else {
            print("Esta mal cantidad: \(quantityString)")
            return 0
        }
        return quantityTreated
    }
    private func getTreatedAmount(_ input: String) -> Money {
        let prices = input.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard var priceString = prices.first else {
            return Money(0)
        }
        priceString = priceString.replacingOccurrences(of: ",", with: "")
        if priceString.contains(".") {
            priceString = priceString.replacingOccurrences(of: ".", with: "")
        } else {
            priceString += "00"
        }
        guard let priceTreated = Int(priceString) else {
            print("Esta mal: \(priceString)")
            return Money(0)
        }
        return Money(priceTreated)
    }
}
