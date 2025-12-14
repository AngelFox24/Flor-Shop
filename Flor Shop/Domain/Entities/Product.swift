import Foundation
import FlorShopDTOs

struct Product: Identifiable, Codable {
    var id: UUID
    let productCic: String?
    var active: Bool
    var barCode: String?
    var name: String
    var qty: Int
    var unitType: UnitType
    var unitCost: Money
    var unitPrice: Money
    var expirationDate: Date?
    var imageUrl: String?
    
    static func getDummyProduct() -> Product {
        return Product(
            id: UUID(),
            productCic: UUID().uuidString,
            active: true,
            name: "No existe",
            qty: 0,
            unitType: .unit,
            unitCost: .init(0),
            unitPrice: .init(0)
        )
    }
}

extension Product {
    func toProductDTO() -> ProductServerDTO {
        return ProductServerDTO(
            productCic: productCic,
            productName: name,
            barCode: barCode ?? "",//TODO: barcode shoul'd be optional
            active: active,
            expirationDate: expirationDate,
            quantityStock: qty,
            unitType: unitType,
            unitCost: unitCost.cents,
            unitPrice: unitPrice.cents,
            imageUrl: imageUrl
        )
    }
    func isEquals(to other: Product) -> Bool {
        return (
            self.productCic == other.productCic &&
            self.name == other.name &&
            self.barCode == other.barCode &&
            self.qty == other.qty &&
            self.unitPrice == other.unitPrice &&
            self.unitCost == other.unitCost &&
            self.expirationDate == other.expirationDate &&
            self.active == other.active &&
            self.imageUrl == other.imageUrl
        )
    }
}

