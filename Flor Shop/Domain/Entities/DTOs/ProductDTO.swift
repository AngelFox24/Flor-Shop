//
//  ProductDTO.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

struct ProductDTO: Codable {
    let id: UUID
    let productName: String
    let barCode: String
    let active: Bool
    let expirationDate: Date?
    let quantityStock: Int
    let unitType: String
    let unitCost: Int
    let unitPrice: Int
    let subsidiaryId: UUID
    let imageUrl: ImageURLDTO?
    let createdAt: String
    let updatedAt: String
}

extension ProductDTO {
    func toProduct() -> Product {
        return Product(
            id: id,
            active: active,
            barCode: barCode,
            name: productName,
            qty: quantityStock,
            unitType: unitType == "Unit" ? .unit : .kilo,
            unitCost: Money(unitCost),
            unitPrice: Money(unitPrice),
            expirationDate: expirationDate,
            image: nil,
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
    func isEquals(to other: Tb_Product) -> Bool {
        var imageIsEquals = false
        if let image = self.imageUrl, let otherImage = other.toImageUrl {
            imageIsEquals = image.isEquals(to: otherImage)
        } else {
            imageIsEquals = true
        }
        return (
            self.id == other.idProduct &&
            self.productName == other.productName &&
            self.barCode == other.barCode &&
            self.active == other.active &&
            self.expirationDate == other.expirationDate &&
            self.quantityStock == other.quantityStock &&
            self.unitType == other.unitType &&
            self.unitCost == other.unitCost &&
            self.unitPrice == other.unitPrice &&
            self.imageUrl?.id == other.toImageUrl?.idImageUrl &&
            imageIsEquals
        )
    }
}

extension Array where Element == ProductDTO {
    func mapToListProducts() -> [Product] {
        return self.compactMap {$0.toProduct()}
    }
}
