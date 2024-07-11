//
//  Product.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation

struct Product: Identifiable {
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
    
    static func getDummyProduct() -> Product {
        return Product(
            id: UUID(),
            active: true,
            name: "No existe",
            qty: 0,
            unitType: .unit,
            unitCost: Money(cents: 0),
            unitPrice: Money(cents: 0)
        )
    }
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}
