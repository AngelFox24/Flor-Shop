import Foundation
import FlorShop_DTOs
import CoreData

struct Product: Identifiable, Codable, Equatable {
    var id: UUID
    let productId: UUID?
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
            productId: nil,
            active: true,
            name: "No existe",
            qty: 0,
            unitType: .unit,
            unitCost: Money(0),
            unitPrice: Money(0)
        )
    }
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Product {
    func toProductDTO(subsidiaryId: UUID) -> ProductServerDTO {
        return ProductServerDTO(
            id: productId,
            productName: name,
            barCode: barCode ?? "",
            active: active,
            expirationDate: expirationDate,
            quantityStock: qty,
            unitType: unitType.rawValue,
            unitCost: unitCost.cents,
            unitPrice: unitPrice.cents,
            subsidiaryId: subsidiaryId,
            imageUrl: image?.toImageUrlDTO()
        )
    }
    func isEquals(to other: Product) -> Bool {
        let imageIsEquals: Bool
        if let image = self.image {
            imageIsEquals = image.isEquals(to: other.image)
        } else {
            imageIsEquals = other.image == nil
        }
        return (
            self.productId == other.productId &&
            self.name == other.name &&
            self.barCode == other.barCode &&
            self.qty == other.qty &&
            self.unitPrice == other.unitPrice &&
            self.unitCost == other.unitCost &&
            self.expirationDate == other.expirationDate &&
            self.active == other.active &&
            self.image?.id == other.image?.id &&
            imageIsEquals
        )
    }
}

