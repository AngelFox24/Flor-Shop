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
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func execute(url: URL) async {
        print("Importando CSV")
        await loadTestData(url: url)
    }
    private func loadTestData(url: URL) async {
        if let content = try? String(contentsOfFile: url.absoluteString, encoding: .utf8) {
            do {
                let lines = content.components(separatedBy: "\n")
                var countSucc: Int = 0
                var countFail: Int = 0
                for line in lines {
                    let elements = line.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    if elements.count != 3 {
                        print("Count: \(elements.count)")
                        countFail = countFail + 1
                        continue
                    }
                    let date = Date()
                    let unitType = getTreatedUnitType(elements[2])
                    let quantity = getTreatedQuantity(quantity: elements[2], unitType: unitType)
                    let product = Product(
                        id: UUID(),
                        active: true,
                        name: elements[1],
                        qty: quantity,
                        unitType: unitType,
                        unitCost: getTreatedAmount(elements[2]),
                        unitPrice: getTreatedAmount(elements[2]),
                        expirationDate: nil,
                        image: ImageUrl(id: UUID(), imageUrl: elements[0], imageHash: "", createdAt: date, updatedAt: date),
                        createdAt: date,
                        updatedAt: date
                    )
                    do {
//                        try await productRepository.save(product: product)
                        countSucc += 1
                    } catch {
                        countFail += 1
                    }
                }
                print("Total: \(lines.count), Success: \(countSucc), Fails: \(countFail)")
            } catch {
                print("Error al leer el archivo: \(error)")
            }
        } else {
            print("No se encuentra el archivo")
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
