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
    
//    // Incluyendo CodingKeys para mapear los campos del JSON a las propiedades del struct
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case active
//        case barCode
//        case name = "productName"
//        case qty = "quantityStock"
//        case unitType
//        case unitCost
//        case unitPrice
//        case expirationDate
//        case image = "imageUrl"
//        case createdAt
//        case updatedAt
//    }
    
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
    func toProductEntity(context: NSManagedObjectContext) -> Tb_Product? {
        let filterAtt = NSPredicate(format: "idProduct == %@", id.uuidString)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        do {
            let productEntity = try context.fetch(request).first
            return productEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
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
            imageUrl: image?.toImageUrlDTO(),
            createdAt: createdAt.description,
            updatedAt: updatedAt.description
        )
    }
}

extension Array where Element == Product {
    func mapToListProductEntity(context: NSManagedObjectContext) -> [Tb_Product] {
        return self.compactMap {$0.toProductEntity(context: context)}
    }
}

