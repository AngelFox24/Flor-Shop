import Foundation
import FlorShop_DTOs

extension SaleClientDTO {
    func toSale() -> Sale {
        return Sale(
            id: id,
            paymentType: PaymentType.from(description: paymentType),
            saleDate: saleDate,
            saleDetail: saleDetail.mapToListSaleDetail(paymentType: paymentType, saleDate: saleDate),
            totalSale: Money(total)
        )
    }
    func isEquals(to other: Tb_Sale) -> Bool {
        return (
            self.id == other.idSale &&
            self.paymentType == other.paymentType
        )
    }
}

extension Array where Element == SaleClientDTO {
    func mapToListSale() -> [Sale] {
        return self.compactMap({$0.toSale()})
    }
}
