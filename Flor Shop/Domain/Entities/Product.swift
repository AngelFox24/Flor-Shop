//
//  Product.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

struct Product: Identifiable {
    var id: UUID
    var name: String
    var qty: Int
    var unitCost: Double
    var unitPrice: Double
    var expirationDate: Date?
    var totalCost: Double
    var profitMargin: Double
    var keyWords: String
    var image: ImageUrl
    init(id: UUID, name: String, qty: Int, unitCost: Double, unitPrice: Double, expirationDate: Date?, image: ImageUrl) {
        self.id = id
        self.name = name
        self.qty = Int(qty)
        self.unitCost = unitCost
        self.unitPrice = unitPrice
        self.expirationDate = expirationDate
        self.totalCost = 0
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
        if qty == Int64(0.0) {
            return false
        } else {
            return true
        }
    }
    func isUnitCostValid() -> Bool {
        if unitCost > 0.0 {
            return true
        } else {
            return false
        }
    }
    func isUnitPriceValid() -> Bool {
        if unitPrice > 0.0 {
            return true
        } else {
            return false
        }
    }
    func isExpirationDateValid() -> Bool {
        return true
    }
    static func getDummyProduct() -> Product {
        return Product(id: UUID(), name: "No existe", qty: 0, unitCost: 0, unitPrice: 0, expirationDate: nil, image: ImageUrl.getDummyImage())
    }
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}
