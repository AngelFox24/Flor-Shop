import Foundation
import FlorShopDTOs

extension ProductClientDTO {
//    func toProduct() -> Product {
//        return Product(
//            id: id,
//            productId: id,
//            active: active,
//            barCode: barCode,
//            name: productName,
//            qty: quantityStock,
//            unitType: unitType == "Unit" ? .unit : .kilo,
//            unitCost: Money(unitCost),
//            unitPrice: Money(unitPrice),
//            expirationDate: expirationDate,
//            image: nil
//        )
//    }
    func isEquals(to other: Tb_Product) -> Bool {
        return (
            self.productCic == other.productCic &&
            self.productName == other.productName &&
            self.barCode == other.barCode &&
            self.imageUrl == other.imageUrl &&
            self.syncToken == other.syncToken
        )
    }
}

//extension Array where Element == ProductClientDTO {
//    func mapToListProducts() -> [Product] {
//        return self.compactMap {$0.toProduct()}
//    }
//}
