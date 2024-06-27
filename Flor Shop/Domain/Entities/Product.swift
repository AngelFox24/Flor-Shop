//
//  Product.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation

//extension Double {
//    func rounded(toPlaces places: Int) -> Double {
//        let divisor = pow(10.0, Double(places))
//        return (self * divisor).rounded() / divisor
//    }
//}

struct Product: Identifiable {
    var id: UUID
    var active: Bool
    var name: String
    var qty: Int
    var unitType: UnitTypeEnum
    var unitCost: Money
    var unitPrice: Money
    var expirationDate: Date?
    var totalCost: Money
    var profitMargin: Int
    var keyWords: String
    var image: ImageUrl?
    init(id: UUID, active: Bool, name: String, qty: Int, unitType: UnitTypeEnum, unitCost: Money, unitPrice: Money, expirationDate: Date?, image: ImageUrl?) {
        self.id = id
        self.active = active
        self.name = name
        self.qty = Int(qty)
        self.unitType = unitType
        self.unitCost = unitCost
        self.unitPrice = unitPrice
        self.expirationDate = expirationDate
        self.totalCost = Money(cents: 0)
        self.profitMargin = 0
        self.keyWords = "Producto"
        self.image = image
    }
    // MARK: Validacion Crear Producto
    func isProductNameValid() -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    func isQuantityValid() -> Bool {
        print("Tipo Unidades")
        if qty == 0 {
            return false
        } else {
            return true
        }
    }
//    func isUnitCostValid() -> Bool {
//        if unitCost > 0 {
//            return true
//        } else {
//            return false
//        }
//    }
//    func isUnitPriceValid() -> Bool {
//        if unitPrice > 0 {
//            return true
//        } else {
//            return false
//        }
//    }
    func isExpirationDateValid() -> Bool {
        return true
    }
    static func getDummyProduct() -> Product {
        return Product(
            id: UUID(),
            active: true,
            name: "No existe",
            qty: 0,
            unitType: UnitTypeEnum.unit,
            unitCost: Money(cents: 0),
            unitPrice: Money(cents: 0),
            expirationDate: nil,
            image: nil
        )
    }
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}
