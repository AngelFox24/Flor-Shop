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
            image: imageUrl?.toImageUrl(),
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
}

extension Array where Element == ProductDTO {
    func mapToListProducts() -> [Product] {
        return self.compactMap {$0.toProduct()}
    }
}
