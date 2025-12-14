import Foundation
import FlorShopDTOs

//extension SaleDetailClientDTO {
//    func toSaleDetail(paymentType: String, saleDate: Date) -> SaleDetail {
//        return SaleDetail(
//            id: id,
//            image: nil,
//            barCode: barCode,
//            productName: productName,
//            unitType: unitType == UnitTypeEnum.unit.rawValue ? .unit : .kilo,
//            unitCost: Money(unitCost),
//            unitPrice: Money(unitPrice),
//            quantitySold: quantitySold,
//            paymentType: PaymentType.from(description: paymentType),
//            saleDate: Date(),
//            subtotal: Money(subtotal)
//        )
//    }
//    func isEquals(to other: Tb_SaleDetail) -> Bool {
//        return (
//            self.id == other.idSaleDetail &&
//            self.productName == other.productName &&
//            self.barCode == other.barCode &&
//            self.quantitySold == other.quantitySold &&
//            self.subtotal == other.subtotal &&
//            self.unitType == other.unitType &&
//            self.unitCost == other.unitCost &&
//            self.unitPrice == other.unitPrice &&
//            self.imageUrlId == other.toImageUrl?.idImageUrl
//        )
//    }
//}
//
//extension Array where Element == SaleDetailClientDTO {
//    func mapToListSaleDetail(paymentType: String, saleDate: Date) -> [SaleDetail] {
//        return self.compactMap({$0.toSaleDetail(paymentType: paymentType, saleDate: saleDate)})
//    }
//}
