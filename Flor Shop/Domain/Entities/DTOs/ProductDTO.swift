import Foundation
import FlorShop_DTOs

extension ProductClientDTO {
    func toProduct() -> Product {
        return Product(
            id: id,
            productId: id,
            active: active,
            barCode: barCode,
            name: productName,
            qty: quantityStock,
            unitType: unitType == "Unit" ? .unit : .kilo,
            unitCost: Money(unitCost),
            unitPrice: Money(unitPrice),
            expirationDate: expirationDate,
            image: nil
        )
    }
    func isEquals(to other: Tb_Product) -> Bool {
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
            self.imageUrlId == other.toImageUrl?.idImageUrl &&
            self.syncToken == other.syncToken
        )
    }
}

extension Array where Element == ProductClientDTO {
    func mapToListProducts() -> [Product] {
        return self.compactMap {$0.toProduct()}
    }
}
