import Foundation
import FlorShopDTOs

extension ProductSubsidiaryClientDTO {
//    func toProductModel() -> Product {
//        return Product(
//            id: UUID(),
//            productCic: productCic,
//            active: active,
//            name: toP,
//            qty: <#T##Int#>,
//            unitType: <#T##UnitType#>,
//            unitCost: <#T##Money#>,
//            unitPrice: <#T##Money#>
//        )
//    }
    func isEquals(to other: Tb_ProductSubsidiary) -> Bool {
        return (
            self.active == other.active &&
            self.expirationDate == other.expirationDate &&
            self.quantityStock == other.quantityStock &&
            self.unitCost == other.unitCost &&
            self.unitPrice == other.unitPrice &&
            self.syncToken == other.syncToken
        )
    }
}

//extension Array where Element == ProductClientDTO {
//    func mapToListProducts() -> [Product] {
//        return self.compactMap {$0.toProduct()}
//    }
//}
