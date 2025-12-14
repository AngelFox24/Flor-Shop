import Foundation
import FlorShopDTOs

extension SaleClientDTO {
//    func toSale() -> Sale {
//        return Sale(
//            id: id,
//            paymentType: PaymentType.from(description: paymentType),
//            saleDate: saleDate,
//            saleDetail: saleDetail.mapToListSaleDetail(paymentType: paymentType, saleDate: saleDate),
//            totalSale: Money(total)
//        )
//    }
    func isEquals(to other: Tb_Sale) -> Bool {
        guard let paymentType = other.paymentType,
              let paymentTypeEnum = PaymentType(rawValue: paymentType) else {
            return false
        }
        return (
            self.id == other.idSale &&
            self.paymentType == paymentTypeEnum &&
            self.syncToken == other.syncToken
        )
    }
}
//
//extension Array where Element == SaleClientDTO {
//    func mapToListSale() -> [Sale] {
//        return self.compactMap({$0.toSale()})
//    }
//}
//
