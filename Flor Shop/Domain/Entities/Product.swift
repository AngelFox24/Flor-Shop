//
//  Product.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation

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
    
    // Incluyendo CodingKeys para mapear los campos del JSON a las propiedades del struct
    private enum CodingKeys: String, CodingKey {
        case id
        case active
        case barCode
        case name = "productName"
        case qty = "quantityStock"
        case unitType
        case unitCost
        case unitPrice
        case expirationDate
        case image = "imageUrl"
        case createdAt
        case updatedAt
    }
    
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

struct ProductRequest: Codable {
    let subsidiaryId: UUID
    let updatedSince: String
}

struct ProductDTO: Codable {
    var id: UUID
    var active: Bool
    var barCode: String?
    var productName: String
    var quantityStock: Int
    var unitType: UnitTypeEnum
    var unitCost: Money
    var unitPrice: Money
    var expirationDate: Date?
    var imageUrl: ImageUrl?
    var subsidiaryId: UUID
    var createdAt: String
    var updatedAt: String
}

struct Money: Codable {
    var cents: Int
    
    // Inicializador para deserialización directa desde un valor entero
    init(_ cents: Int) {
        self.cents = cents
    }
    
    // Propiedad computada para obtener el valor en soles (opcional, según necesidad)
    var soles: Double {
        return Double(cents) / 100.0
    }
    
    // Implementación de Codable para personalizar la serialización
    private enum CodingKeys: String, CodingKey {
        case cents
    }
    
    // Método para convertir a JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(cents)
    }
    
    // Método para convertir desde JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        cents = try container.decode(Int.self)
    }
}
