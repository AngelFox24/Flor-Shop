//
//  Product.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation
import CoreData

struct Product: Identifiable, Codable {
    var id: UUID
    var active: Bool
    var barCode: String?
    var name: String
    var qty: Int
    var unitType: UnitTypeEnum
    var unitCost: Money
    var unitPrice: Money
    var expirationDate: Date?
    var image: ImageUrl?
    var createdAt: Date
    var updatedAt: Date
    
    static func getDummyProduct() -> Product {
        return Product(
            id: UUID(),
            active: true,
            name: "No existe",
            qty: 0,
            unitType: .unit,
            unitCost: Money(0),
            unitPrice: Money(0),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Product {
    func toProductDTO(subsidiaryId: UUID) -> ProductDTO {
        return ProductDTO(
            id: id,
            productName: name,
            barCode: barCode ?? "",
            active: active,
            expirationDate: expirationDate,
            quantityStock: qty,
            unitType: unitType.rawValue,
            unitCost: unitCost.cents,
            unitPrice: unitPrice.cents,
            subsidiaryId: subsidiaryId,
            imageUrl: image?.toImageUrlDTO(imageData: nil),
            createdAt: ISO8601DateFormatter().string(from: createdAt),
            updatedAt: ISO8601DateFormatter().string(from: updatedAt)
        )
    }
}

